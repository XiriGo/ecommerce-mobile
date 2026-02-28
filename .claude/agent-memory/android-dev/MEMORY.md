# Android Dev Agent Memory

## Import Ordering (ktlint / .editorconfig)

The `.editorconfig` at `/Users/atakan/Documents/GitHub/xirigo/ecommerce-mobile/android/.editorconfig` defines import ordering:

```
ij_kotlin_imports_layout = *,java.**,javax.**,android.**,androidx.**,com.xirigo.**
```

Groups separated by blank lines, in this order:
1. `*` (catch-all: `org.junit.**`, `kotlin.**`, etc.)
2. `java.**`
3. `javax.**`
4. `android.**`
5. `androidx.**`
6. `com.xirigo.**`

This is a common CI failure source -- test files often mix `org.junit` imports inline with `androidx` imports without grouping.

## Key File Paths

- Android source root: `android/app/src/main/java/com/xirigo/ecommerce/`
- Android test root: `android/app/src/androidTest/java/com/xirigo/ecommerce/`
- Design system: `android/app/src/main/java/com/xirigo/ecommerce/core/designsystem/`
- EditorConfig: `android/.editorconfig`
