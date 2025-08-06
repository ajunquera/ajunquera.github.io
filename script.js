function buildTree(data, level = 1) { // add level parameter and default value
  const ul = document.createElement("ul");

  ul.classList.add(`level-${level}`);  // add CSS class with the level

  data.forEach(item => {
    const li = document.createElement("li");

    if (item.children) {
      const span = document.createElement("span");
      span.textContent = `${item.code} - ${item.name}`;
      span.classList.add("toggle");

      const childUl = buildTree(item.children, level + 1); // change level
      childUl.classList.add("hidden");

      span.onclick = () => childUl.classList.toggle("hidden");

      li.appendChild(span);
      li.appendChild(childUl);
    } else {
      li.textContent = `${item.code} - ${item.name}`;
    }

    ul.appendChild(li);
  });

  return ul;
}

fetch("cno-sispe-8d-hi.json")
  .then(response => response.json())
  .then(data => {
    const treeContainer = document.getElementById("tree");
    treeContainer.innerHTML = "";  // limpiar "Cargando..."
    treeContainer.appendChild(buildTree(data));
  })
  .catch(error => {
    document.getElementById("tree").textContent = "Error al cargar datos.";
    console.error(error);
  });