import Compiler from "./compiler.worker.js";

const worker = new Worker(new URL('./compiler.worker.js', import.meta.url));
const terminalText = document.getElementById("terminalText");

worker.onmessage = (evt) => {
  terminalText.textContent += evt.data;
};

const readFile = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);

    reader.readAsText(file);
  });

const navbarInput = document.getElementById("navbarInput");
const navbarUploadButton = document.getElementById("navbarUploadButton");

navbarUploadButton.addEventListener("click", (evt) => {
  evt.preventDefault();

  navbarInput.click();
});

navbarInput.addEventListener("change", (evt) => {
  evt.preventDefault();

  // evt.target.files is a FileList
  const files = Array.from(evt.target.files);

  files.forEach((file) => {
    console.log("changed", file);
  });
});

const editorPane = document.getElementById("editorPane");
const terminalPane = document.getElementById("terminalPane");
const resizer = document.getElementById("resizer");

let leftWidth = editorPane.getBoundingClientRect().width;
let resizing = false;
let xPos = undefined;

resizer.addEventListener("mousedown", (evt) => {
  evt.preventDefault();

  resizing = true;
  xPos = evt.clientX;
});

window.addEventListener("mouseup", (evt) => {
  if (resizing) {
    evt.preventDefault();

    resizing = false;
  }
});

window.addEventListener("mousemove", (evt) => {
  if (resizing) {
    evt.preventDefault();

    const newX = evt.clientX;
    leftWidth += newX - xPos;
    editorPane.style.width = `${leftWidth}px`;
    xPos = newX;
  }
});

editorPane.style.width = `${leftWidth}px`;
