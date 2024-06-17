import { bytesToBigInt, fromHex } from "@zk-email/helpers";
import { generateEmailVerifierInputsFromDKIMResult } from "@zk-email/helpers";
import { generateEmailVerifierInputs } from "@zk-email/helpers/dist/input-generators";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim"
import fs from "fs"
import path from "path"
 
export const STRING_PRESELECTOR = "password reset for @";
export const MAX_HEADER_PADDED_BYTES = 1024;
export const MAX_BODY_PADDED_BYTES = 1536;
 
export async function generateTwitterVerifierCircuitInputs() {
  const rawEmail = fs.readFileSync(path.join(__dirname, "../emls/rawEmail.eml"), "utf8");

  const address = bytesToBigInt(fromHex("0x71C7656EC7ab88b098defB751B7401B5f6")).toString();
  
  const dkimResult = await verifyDKIMSignature(Buffer.from(rawEmail));
  
  const emailVerifierInputs = await generateEmailVerifierInputsFromDKIMResult(dkimResult);

  console.log("pubkey=", emailVerifierInputs.pubkey.join(","))

  console.log("emailBody=", emailVerifierInputs.emailBody)

  const bodyRemaining = emailVerifierInputs.emailBody!.map((c) => Number(c)); // Char array to Uint8Array
  console.log("bodyRemaining=", bodyRemaining)
  const selectorBuffer = Buffer.from(STRING_PRESELECTOR);
  const selectorIndex = Buffer.from(bodyRemaining).indexOf(selectorBuffer);
  const usernameIndex = selectorIndex + selectorBuffer.length;

  console.log("selectorIndex=", selectorIndex, ", selectorBuffer.length=", selectorBuffer.length,", usernameIndex=", usernameIndex, ", value=", bodyRemaining[usernameIndex]);

  const inputJson = {
    ...emailVerifierInputs,
    twitterUsernameIndex: usernameIndex.toString(),
    address,
  };
  fs.writeFileSync("./target/input.json", JSON.stringify(inputJson))
}
 
(async () => {
    await generateTwitterVerifierCircuitInputs();
}) ();