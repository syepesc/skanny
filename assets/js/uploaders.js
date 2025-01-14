let Uploaders = {}

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach(entry => {
    let xhr = new XMLHttpRequest()
    
    onViewError(() => xhr.abort())

    xhr.onload = () => xhr.status === 200 ? entry.progress(100) : entry.error()
    xhr.onerror = () => entry.error()

    // Learn more about xhr event listeners here -> https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest_API/Using_XMLHttpRequest#monitoring_progress
    xhr.upload.addEventListener("progress", (event) => {
      if(event.lengthComputable){
        let percent = Math.round((event.loaded / event.total) * 100)
        if(percent < 100){ entry.progress(percent) }
      }
    })

    let url = entry.meta.url
    
    xhr.open("PUT", url, true)
    xhr.send(entry.file)
  })
}

export default Uploaders;