# Markdown Code Block Formatting Playground

Use this file to test formatting fenced code blocks without formatting prose into a different shape.

## JavaScript

```javascript
const user = { name: "Ada", items: [1, 2, 3] };
function greet(name) {
  return `hello ${name}`;
}
```

## TypeScript

```typescript
type User = { id: string; name: string };
const users: User[] = [{ id: "1", name: "Ada" }];
```

## Lua

```lua
local values = { 1, 2, 3 }
for _, value in ipairs(values) do
  print(value)
end
```

## Shell transcript should be reviewed manually

```console
$ echo "not every fenced block is source code"
not every fenced block is source code
```
