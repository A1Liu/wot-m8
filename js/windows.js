const ROOT = "windows-root";

const RESIZER = "windows-resizer";
const TABBED = "windows-tabbed";
const TAB_BAR = "windows-tabbar";
const TAB = "windows-tab";

const HORIZONTAL = "windows-horizontal"; // left-to-right
const VERTICAL = "windows-vertical"; // top-to-bottom

export const AFTER = "windows-AFTER";
export const BEFORE = "windows-BEFORE";

export const root = document.getElementById(ROOT);

export const TabbedWindow = (title, content) => {
  const tabbedWindow = document.createElement("div");
  const tabBar = document.createElement("div");
  const tab = document.createElement("div");

  tabbedWindow.classList.add(TABBED);
  tabBar.classList.add(TAB_BAR);
  tab.classList.add(TAB);

  tab.textContent = title;

  tabBar.appendChild(tab);
  tabbedWindow.appendChild(tabBar);
  tabbedWindow.appendChild(content);

  return tabbedWindow;
};

export const addHorizontalSibling = (domNode, child, position = AFTER) => {
  const parent = domNode.parent;
  if (parent.classList.contains(HORIZONTAL) || parent.id === ROOT) {
    domNode.insertAdjacentElement("beforebegin", child);

    return;
  }
};

let resizeState = null;

/* {
  parent: DomNode,
  nodeBeforeResize: DomNode,
  nodeAfterResize: DomNode,
  nodeBeingDragged: DomNode,
  mostRecentPos: number,
  mostRecentLeftSize: number,
  mostRecentBeforeSize: number,
  initialTotalSize: number,
}; */

export const appendChild = (parent, child) => {
  const classList = parent.classList;
  const isVertical = classList.contains(VERTICAL);
  const isHorizontal = classList.contains(HORIZONTAL) || parent.id === ROOT;

  if (!isVertical && !isHorizontal) {
    console.warn("tried to append to invalid value");
    return;
  }

  if (parent.children.length <= 0) {
    parent.appendChild(child);
    return;
  }

  const resizerLeft = parent.lastChild;

  const resizer = document.createElement("span");
  resizer.classList.add(RESIZER);
  resizer.classList.add(isVertical ? "vertical" : "horizontal");
  resizer.role = "presentation";

  const parentWidth = parent.getBoundingClientRect().width;
  let leftWidth = parentWidth / 2;
  let resizing = false;
  let xPos = null;

  // TODO cleanup event listeners added to window
  resizer.addEventListener("mousedown", (evt) => {
    evt.preventDefault();
    evt.stopPropagation();

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
      resizerLeft.style.width = `${leftWidth}px`;
      child.style.width = `${parentWidth - leftWidth}px`;
      xPos = newX;
    }
  });

  resizerLeft.style.width = `${leftWidth}px`;
  child.style.width = `${leftWidth}px`;

  parent.appendChild(resizer);
  parent.appendChild(child);

  return;
};
