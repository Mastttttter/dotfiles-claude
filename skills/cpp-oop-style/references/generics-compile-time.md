# Generics & Compile-Time Dispatch

When the set of types is known at compile time, resolve behavior at compile time —
no vtable, no heap, no runtime branch. The governing idea:

> **Duck typing with a checked contract.** A template already accepts any type
> that "quacks right"; `concept` / `requires` makes that contract explicit, and
> `if constexpr` picks the branch per type before any code is generated.

This is the static twin of the polymorphism in `SKILL.md` — reach for it when the
type set is *closed and known*, prefer a `virtual` interface when it is *open*.

## `if constexpr` — compile-time branch

A `constexpr` condition decided at compile time. The dead branch is **not
compiled**, so it may legally contain code that wouldn't compile for this type:

```cpp
template <class T>
void greet(T const &animal) {
    animal.bark();
    if constexpr (!std::is_same_v<T, Goldfish>) {   // pruned for Goldfish
        animal.intro();                             // Goldfish has no intro() — never compiled
    }
}
```

No branch instruction reaches the generated assembly, optimization on or off. This
is the compile-time form of the template-`Func` / `auto`-param dispatch the main
skill already teaches.

## `requires` — does this expression compile?

`requires { expr; }` is a `constexpr bool`: `true` if `expr` would compile. Use it
to detect whether a type supports a member, then `if constexpr` on the result:

```cpp
template <class T>
void greet(T const &dog) {
    if constexpr (requires { dog.intro(); }) dog.intro();   // call it only if it exists
    dog.bark();
}
```

A `requires (T t) { ... }` introduces compile-time-only sample variables (no
runtime cost), and several statements all must compile:
`requires { ++it; --it; }` ≡ `requires { ++it; } && requires { --it; }`.

## `concept` — name the contract

Hoist a recurring `requires` into a named `concept` (a `constexpr bool` variable
template). A type that satisfies the concept *is* that concept — duck typing with a
name:

```cpp
template <class It> concept RandomAccess = requires (It it, int n) { it += n; it -= n; };
template <class It> concept Bidirectional = requires (It it) { ++it; --it; };

template <class It>
void advance(It &it, int n) {
    if constexpr (RandomAccess<It>)      it += n;          // pick the best per type
    else if constexpr (Bidirectional<It>) while (n-- > 0) ++it;
    else throw std::logic_error("It is not an iterator");
}
```

Use a concept to **constrain a template parameter** so callers get a clear error
instead of a deep instantiation dump, and so the right overload is chosen:

```cpp
void sort(RandomAccess auto first, RandomAccess auto last);   // C++20 constrained auto
template <RandomAccess It> void sort(It first, It last);      // equivalent long form
```

Prefer the standard `<concepts>` (`std::integral`, `std::ranges::range`, …) before
rolling your own.

## `std::variant` + `std::visit` — closed-set value polymorphism

When the type set is **fixed and known**, a `variant` gives polymorphism with
value semantics — no heap, no vtable, no `virtual ~T()`:

```cpp
using Shape = std::variant<Circle, Square, Triangle>;

double area(Shape const &s) {
    return std::visit([](auto const &x) { return x.area(); }, s);   // one generic lambda
}
```

For per-type branches, the `overloaded` helper turns several lambdas into one
visitor:

```cpp
template <class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template <class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

std::visit(overloaded{
    [](Circle const &c)   { return draw(c); },
    [](Square const &s)   { return draw(s); },
    [](Triangle const &t) { return draw(t); },
}, shape);
```

Choose by openness: a **closed** set you control → `variant` (the alternatives
can't grow without editing the `using`); an **open** set extended by other modules
or plugins → a `virtual` interface (`SKILL.md` Compose / Visitor). `variant` also
wins when you want value copies and no allocation.

## Perfect forwarding & exact return types (advanced)

For a zero-overhead generic wrapper or factory, take `auto &&` (a forwarding
reference) and pass it on with `std::forward` so the value category (lvalue /
rvalue) is preserved — a copy isn't forced where a move was possible:

```cpp
auto logged(auto &&...args) {
    log("calling");
    return target(std::forward<decltype(args)>(args)...);   // preserve lvalue/rvalue
}
```

Use `decltype(auto)` (not plain `auto`, which decays) when a wrapper must return
*exactly* what the inner call returns, references included:

```cpp
decltype(auto) front(auto &c) { return c.front(); }   // returns T& / T const&, not a copy
```
