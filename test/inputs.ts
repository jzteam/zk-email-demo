import { bytesToBigInt, fromHex } from "@zk-email/helpers";
import { generateEmailVerifierInputsFromDKIMResult } from "@zk-email/helpers";
import { generateEmailVerifierInputs } from "@zk-email/helpers/dist/input-generators";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim";
import fs from "fs";
import path from "path";

const ARGS = process.argv.slice(2);
console.log("ARGS=", ARGS);
const emlPath = ARGS[0] ? ARGS[0] : "emls/rawEmail.eml";
const inputPath = ARGS[1] ? ARGS[1] : "target/input.json";

export const STRING_PRESELECTOR = "password reset for @";
export const MAX_HEADER_PADDED_BYTES = 1024;
export const MAX_BODY_PADDED_BYTES = 1536;

export async function generateTwitterVerifierCircuitInputs(
  emlPath = "emls/rawEmail.eml",
  inputPath = "target/input.json",
) {
  const rawEmail = fs.readFileSync(emlPath, "utf8");

  const address = bytesToBigInt(
    fromHex("0x71C7656EC7ab88b098defB751B7401B5f6"),
  ).toString();

  const dkimResult = await verifyDKIMSignature(Buffer.from(rawEmail));

  const emailVerifierInputs =
    await generateEmailVerifierInputsFromDKIMResult(dkimResult);

  console.log("pubkey=", emailVerifierInputs.pubkey.join(","));

  console.log("emailBody=", emailVerifierInputs.emailBody);

  const bodyRemaining = emailVerifierInputs.emailBody!.map((c) => Number(c)); // Char array to Uint8Array
  console.log("bodyRemaining=", bodyRemaining);
  const selectorBuffer = Buffer.from(STRING_PRESELECTOR);
  const selectorIndex = Buffer.from(bodyRemaining).indexOf(selectorBuffer);
  const usernameIndex = selectorIndex + selectorBuffer.length;

  console.log(
    "selectorIndex=",
    selectorIndex,
    ", selectorBuffer.length=",
    selectorBuffer.length,
    ", usernameIndex=",
    usernameIndex,
    ", value=",
    bodyRemaining[usernameIndex],
  );

  const inputJson = {
    ...emailVerifierInputs,
    twitterUsernameIndex: usernameIndex.toString(),
    address,
  };
  fs.writeFileSync(inputPath, JSON.stringify(inputJson));
}

(async () => {
  await generateTwitterVerifierCircuitInputs(emlPath, inputPath);
})();
