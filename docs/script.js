// list of available pdf files
const pdfFiles = [
    "Advanced Databases.pdf",
    "Advanced Programming.pdf",
    "Algorithm Engineering.pdf",
    "Compilation Techniques.pdf",
    "Models for Programming Paradigms.pdf",
    "Program Analysis.pdf",
    "Parallel and Distributed Systems Paradigms and Models.pdf"
];

const listElement = document.getElementById('pdf-list');

if (!listElement) {
    console.error("ERROR: TARGET ELEMENT 'pdf-list' NOT FOUND IN DOM");
} else {
    console.log("STARTING DOM POPULATION...");
    
    // create and attach elements for each file
    pdfFiles.forEach(file => {
        const li = document.createElement('li');
        li.className = 'pdf-card';
        
        const a = document.createElement('a');
        a.href = file; 
        a.target = '_blank'; // opens pdf in a new tab
        a.textContent = file.replace('.pdf', ''); 
        
        li.appendChild(a);
        listElement.appendChild(li);
    });

    console.log("PDF LIST RENDERED SUCCESSFULLY");
}