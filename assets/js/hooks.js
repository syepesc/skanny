let Hooks = {}

Hooks.DragAndDropHook = {
  mounted() {
    let dropArea = this.el;

    function preventDefaults(e) {
      e.preventDefault();
    }

    // Prevent default behaviors
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropArea.addEventListener(eventName, preventDefaults, false);
    });

    // Add hover effect when file is dragged over
    ['dragenter', 'dragover'].forEach(eventName => {
      dropArea.addEventListener(eventName, () => {
        dropArea.classList.add('hover');
      }, false);
    });
    
    // Remove hover effect when file is dragged out
    ['dragleave', 'drop'].forEach(eventName => {
      dropArea.addEventListener(eventName, () => {
        dropArea.classList.remove('hover');
      }, false);
    });
  }
};
  
Hooks.HandleUploadInProgress = {
  updated () {
    // push event to let the server handle the logic
    this.pushEvent("handle-upload-in-progress", {})
  }
};

export default Hooks;
