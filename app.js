import express from "express";
import { dirname } from "path";
import { fileURLToPath } from "url";
const __dirname2 = dirname(fileURLToPath(import.meta.url));

const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.sendFile(__dirname2 + "/public/index.html");
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
