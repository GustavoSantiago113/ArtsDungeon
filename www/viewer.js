Shiny.addCustomMessageHandler("load_pointcloud", function (message) {
  const containerId = message.id;
  const modelUrl = message.url;

  const container = document.getElementById(containerId);
  if (!container) {
    console.error("Container not found:", containerId);
    return;
  }

  // Clear previous renderers if any
  while (container.firstChild) {
    container.removeChild(container.firstChild);
  }

  const fullScreenRenderer = vtk.Rendering.Misc.vtkFullScreenRenderWindow.newInstance({
    rootContainer: container,
    background: [0.161, 0.451, 0.451],
    containerStyle: {
      width: "100%",
      height: "100%",
      position: "relative",
    },
  });

  const renderer = fullScreenRenderer.getRenderer();
  const renderWindow = fullScreenRenderer.getRenderWindow();

  const reader = vtk.IO.Geometry.vtkPLYReader.newInstance();
  const mapper = vtk.Rendering.Core.vtkMapper.newInstance({ scalarVisibility: false });
  const actor = vtk.Rendering.Core.vtkActor.newInstance();

  actor.setMapper(mapper);
  mapper.setInputConnection(reader.getOutputPort());
  renderer.addActor(actor);

  fetch(modelUrl)
    .then(response => response.arrayBuffer())
    .then(buffer => {
      mapper.setScalarVisibility(true);
      reader.parseAsArrayBuffer(buffer);
      renderer.resetCamera();
      renderWindow.render();
    })
    .catch(error => console.error("Failed to load point cloud:", error));
});