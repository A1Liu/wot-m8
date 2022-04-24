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

const editorPane = document.createElement("div");

editorPane.classList.add("leftPane");
terminalText.classList.add("rightPane");
terminalText.classList.add("terminalText");

windows.appendChild(windows.root, editorPane);
windows.appendChild(windows.root, windows.TabbedWindow("Terminal", terminalText));
