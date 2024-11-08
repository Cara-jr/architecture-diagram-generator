async function uploadFile() {
    const fileInput = document.getElementById('codeFile');
    if (fileInput.files.length === 0) {
        alert('Please select a file.');
        return;
    }
    const file = fileInput.files[0];
    const reader = new FileReader();
    reader.onload = async function() {
        const arrayBuffer = reader.result;
        const base64CodeContent = btoa(String.fromCharCode(...new Uint8Array(arrayBuffer)));
        const payload = {
            code_content: base64CodeContent
        };
        const response = await fetch('https://your-api-gateway-endpoint/prod/generate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await response.json();
        if (response.ok) {
            // The response contains the execution ARN
            const executionArn = data.executionArn;
            // Poll for the execution result
            pollExecutionResult(executionArn);
        } else {
            alert('Error: ' + data.errorMessage);
        }
    };
    reader.readAsArrayBuffer(file);
}

async function pollExecutionResult(executionArn) {
    const response = await fetch(`https://your-api-gateway-endpoint/prod/execution-status?executionArn=${encodeURIComponent(executionArn)}`);
    const data = await response.json();
    if (data.status === 'SUCCEEDED') {
        const output = JSON.parse(data.output);
        document.getElementById('diagramImage').src = output.svg_diagram_url;
        const pseudocodeText = await (await fetch(output.pseudocode_url)).text();
        document.getElementById('pseudocode').innerText = pseudocodeText;
        const umlCodeText = await (await fetch(output.uml_code_url)).text();
        document.getElementById('umlCode').innerText = umlCodeText;

        // Store URLs for downloading
        window.downloadUrls = {
            pseudocode: output.pseudocode_url,
            umlCode: output.uml_code_url,
            svgDiagram: output.svg_diagram_url
        };
    } else if (data.status === 'RUNNING') {
        // Wait and poll again
        setTimeout(() => pollExecutionResult(executionArn), 2000);
    } else {
        alert('Error in execution: ' + data.errorMessage);
    }
}
