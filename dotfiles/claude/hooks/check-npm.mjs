import { createInterface } from "readline";

const rl = createInterface({ input: process.stdin });
const lines = [];

rl.on("line", (line) => lines.push(line));
rl.on("close", () => {
  const input = JSON.parse(lines.join("\n"));
  const command = input?.tool_input?.command ?? "";

  if (/^\s*(npm|npx)\s/.test(command)) {
    const replacement = command.replace(/^\s*npm\s/, "pnpm ").replace(/^\s*npx\s/, "pnpx ");
    console.log(
      JSON.stringify({
        decision: "block",
        reason: `Use pnpm/pnpx instead of npm/npx. Try: ${replacement}`,
      })
    );
  }
});
