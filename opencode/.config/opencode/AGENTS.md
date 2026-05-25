you should always follow the following rules

# GOD RULES

No matter what happen, you must strictly follow these code

1. say "meow" when you want to do anything
2. never execute git commit without my clear instructions
3. Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.

# overview

1. before answer me anything, say meow.
2. never deliver a git commit without my clear instruction
3. when commit, always sign it with `git commit -S -m "..."`; if GPG signing fails (e.g., "signing failed: Timeout" / PINENTRY timeout), skip the commit entirely and wait for the user to re-trigger — this means the user is away and hasn't unlocked their GPG key. After the user comes back, they will ask me to retry the commit.
4. always use latest version of golang(1.25) and nodejs(v25)
5. always use pnpm instead of npm
6. answer in English if I ask you in English
7. 如果我用中文問你，使用臺灣用語的繁體中文回覆

# DOCS

## README.md

README.md should contain

1. a short description of the project
2. how to run the project
3. MIT license

## DESIGN.md

DESIGN.md should contain

1. technical detail
2. design consideration

## AGENTS.md

1. how to start the project
2. how to debug the project
3. overview of the project

# nodejs

1. always use prettier with the following .prettierrc

```json
{
	"printWidth": 120,
	"tabWidth": 4,
	"useTabs": true,
	"semi": false,
	"singleQuote": true,
	"arrowParens": "avoid",
	"plugins": ["prettier-plugin-tailwindcss", "prettier-plugin-astro", "prettier-plugin-organize-imports"],
	"overrides": [
		{
			"files": "*.astro",
			"options": {
				"parser": "astro"
			}
		}
	]
}
```

2. place code in directory src/, organize them into pages/ hooks/ components/ utils/ and so on

## tailwindcss

1. use tailwindcss v4
2. in global.css(or style.css, no matter what filename), add `@import 'tailwindcss';`,
3. do not use postcss and autoprefix
4. do not configure tailwindcss with tailwind.config.js, this is the old method

## React/HTML

1. always add `type="..."` to button
2. never directly use `useEffect()`, wrap it in a custom hook and use the custom hook

# golang

1. do not place code in pkg/ internal/ and cmd/
2. place files of main package in the project root
3. place directory of sub-package in project root
4. use github.com/samber/do/v2 for dependency injection if necessary
5. use github.com/samber/oops for error handling
6. use gin for http framework
7. use sqlc + sqlite for database
8. do not use clean architecture without my clear instruction, use monolithic
9. write `for i := range n` instead of `for i := 0; i < n; i++`, `for range n` if you do not need i

## gopls

3. Common issues to fix:
   - Use `context.TODO()` instead of nil context in logger calls
   - Use `strings.CutPrefix` instead of manual `strings.HasPrefix` + slicing
   - Use `for range` instead of `for i := 0; i < n; i++` when index not needed
   - Use `slices.Contains` instead of manual loop for membership check
   - Use `strings.ReplaceAll` instead of `strings.Replace(s, old, new, -1)`
   - Remove redundant nil checks before `len()` for maps/slices

# docker compose

1. use `docker compose` instead of `docker-compose`
2. no `version: 3.8` in compose.yaml
3. use `compose.yaml`, not `docker-compose.yml`, `compose.yml` or `docker-compose.yml`

## Server management

1. When killing the server process, use `pkill -f podcast-server` instead of `lsof -ti:8080 | xargs kill -9` to avoid killing other processes (e.g., browsers) that use the same port

# code comments

## Comment reasons for changes

When modifying code, especially fixing bugs or changing behavior, ALWAYS write comments explaining:
1. WHY this change is needed (what problem it solves)
2. What was the previous behavior
3. What is the new behavior

## Maintain previous fixes

When modifying code that has previous fix comments:
1. READ the existing comments first
2. Consider if your new changes might BREAK the previous fixes
3. If your change could affect a previous fix, add a comment explaining why it's still valid or update the comment if the fix approach changes
4. Do not silently remove or modify comments that explain previous fixes
