const fs = require('fs');
// node test/viewPublic.ts target/RegexEmail/public.json
var filePath = "public.json";
if (process.argv.length > 1) {
  filePath = process.argv[2]
}

fs.readFile(filePath, "utf-8", (err, data) => {

  if (err) { console.log(err); return; }
  const jsonObject = JSON.parse(data);
  const arr = jsonObject.map(n => String.fromCharCode(n))
  console.log(arr)
  const str = arr.join(",");
  console.log(str)
});