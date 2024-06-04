import { bytesToBigInt, fromHex } from "@zk-email/helpers";
import { generateEmailVerifierInputsFromDKIMResult } from "@zk-email/helpers";
import { verifyDKIMSignature } from "@zk-email/helpers/dist/dkim"
import fs from "fs"
import path from "path"
 
export const STRING_PRESELECTOR = "email was meant for @";
export const MAX_HEADER_PADDED_BYTES = 102400;
export const MAX_BODY_PADDED_BYTES = 153600;
 
export async function generateTwitterVerifierCircuitInputs() {
    const rawEmail = fs.readFileSync(
        path.join(__dirname, "./emls/rawEmail.eml"),
        "utf8"
      );
    const dkimResult = await verifyDKIMSignature(Buffer.from(rawEmail));
  const emailVerifierInputs = generateEmailVerifierInputsFromDKIMResult(dkimResult, {maxBodyLength: 153600});
 
    const bodyRemaining = emailVerifierInputs.emailBody!.map(c => Number(c));
    const selectorBuffer = Buffer.from(STRING_PRESELECTOR);
    const usernameIndex = Buffer.from(bodyRemaining).indexOf(selectorBuffer) + selectorBuffer.length;
 
    const address = bytesToBigInt(fromHex("0xDCa9B7e52000e5e0aE07A23EFaaB8613c5f7966B")).toString();
 
    const inputJson = {
        ...emailVerifierInputs,
        twitter_username_idx: usernameIndex.toString(),
        address,
    };
    fs.writeFileSync("./input.json", JSON.stringify(inputJson))
}
 
(async () => {
    await generateTwitterVerifierCircuitInputs();
}) ();