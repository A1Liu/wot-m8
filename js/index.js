import * as windows from "./windows";

const worker = new Worker(new URL("./worker.js", import.meta.url));
const terminalText = document.createElement("textarea");

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

const ROOT = document.getElementById("windows-root");
const navbarInput = document.getElementById("navbarInput");
const navbarUploadButton = document.getElementById("navbarUploadButton");

navbarUploadButton.addEventListener("click", (evt) => {
  evt.preventDefault();

  // navbarInput.click();
  const second = document.createElement("textarea");
  second.classList.add("rightPane");
  second.classList.add("terminalText");

  windows.appendChild(ROOT, windows.TabbedWindow("Terminal", second));
});

navbarInput.addEventListener("change", (evt) => {
  evt.preventDefault();

  // evt.target.files is a FileList
  const files = Array.from(evt.target.files);

  files.forEach((file) => {
    console.log("changed", file);
  });
});

const editorPane = document.createElement("div");
editorPane.classList.add("editorPane");

windows.appendChild(ROOT, editorPane);

// terminalText.classList.add("rightPane");
// terminalText.classList.add("terminalText");

// setTimeout(() => {
//   windows.appendChild(ROOT, windows.TabbedWindow("Terminal", terminalText));
// }, 500);

// setTimeout(() => {
//   const second = document.createElement("textarea");
//   second.classList.add("rightPane");
//   second.classList.add("terminalText");
//
//   windows.appendChild(ROOT, windows.TabbedWindow("Twoie", second));
// }, 1000);
