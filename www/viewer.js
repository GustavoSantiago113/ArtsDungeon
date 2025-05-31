Shiny.addCustomMessageHandler("load_pointcloud", function (message) {
    const containerId = message.id;
    const loaderId = message.loader_id;
    const modelUrl = message.url;

    const container = document.getElementById(containerId);
    const loader = document.getElementById(loaderId);
    
    if (!container) {
        console.error("Container not found:", containerId);
        return;
    }

    console.log("Starting to load point cloud for:", containerId);

    // Clear previous renderers if any
    while (container.firstChild) {
        container.removeChild(container.firstChild);
    }

    fetch(modelUrl)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.arrayBuffer();
        })
        .then(buffer => {
            console.log("Buffer received, showing viewer and initializing VTK...");
            
            // Hide loader first
            if (loader) {
                loader.style.display = 'none';
            }
            
            // Show the container using direct DOM manipulation
            container.style.display = 'block';
            
            // Initialize VTK
            const fullScreenRenderer = vtk.Rendering.Misc.vtkFullScreenRenderWindow.newInstance({
                rootContainer: container,
                background: [1, 1, 1],
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

            mapper.setScalarVisibility(true);
            reader.parseAsArrayBuffer(buffer);
            renderer.resetCamera();
            renderWindow.render();
            
            console.log("Point cloud loaded and rendered successfully");
        })
        .catch(error => {
            console.error("Failed to load point cloud:", error);
            if (loader) {
                loader.style.display = 'none';
            }
            container.style.display = 'block';
            container.innerHTML = '<div style="padding: 20px; text-align: center; color: #dc3545;">Failed to load 3D model</div>';
        });
});