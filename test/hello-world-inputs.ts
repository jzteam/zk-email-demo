import fs from "fs";
import path from "path";

const ARGS = process.argv.slice(2);
console.log("ARGS=", ARGS);
const emlPath = ARGS[0] ? ARGS[0] : "emls/rawEmail.eml";
const inputPath = ARGS[1] ? ARGS[1] : "target/input.json";

export async function generateTwitterVerifierCircuitInputs(
  emlPath = "./emls/rawEmail.eml",
  inputPath = "./target/input.json",
) {
  const inputJson = {
    in1: 1,
    in2: 2,
  };
  console.log("emlPath=", emlPath);
  console.log("inputPath=", inputPath);
  console.log("inputJson=", JSON.stringify(inputJson));
  fs.writeFileSync(inputPath, JSON.stringify(inputJson));
}

(async () => {
  await generateTwitterVerifierCircuitInputs(emlPath, inputPath);
})();
