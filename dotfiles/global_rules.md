# Global Rules

- Prefer a functional style whenever possible
- Prefer immutability over mutability
- Do not add superfluous comments. If the code explains itself, do not add comments

## Rules for nodejs projects

- Check what dependencies are used in the package.json
- If the project is a typescript project and Effect is used use the Effect MCP server to check the documentation
- Check for the existence of pnpm-lock.yaml or yarn.lock or package-lock.json and use the appropriate package manager (pnpm for pnpm-lock.yaml, yarn for yarn.lock, npm for package-lock.json)
- On test files, check if the project uses vitest and use it instead of jest

## Rules for typescript projects

- Never use the `any` type
- Don't use type casts like `as unknown as T` or `as any`
- Prefer `Array.reduce` over for-loops for data aggregation
- Prefer a single `Array.reduce` instead of several iterations using `Array.map` or `Array.filter`, unless the complexity is too high

## Rules for Effect-ts projects

- The form of `return Effect.gen(function* (_) {` that uses the `_` adaptor function is deprecated. There is no need to use such adaptor, just use `return Effect.gen(function* () {` and `yield*` directly any effect
- When dealing with Effect-ts, check the MCP server for the latest documentation
- Effect services should be created using the form of `class ServiceName extends Effect.service<ServiceName> {`
- Add annotations to key effects using `Effect.annotateCurrentSpan` or `Effect.annotateLogs`
- Deriving types from Schema is done using `export const Type = typeof MySchema.Type`
