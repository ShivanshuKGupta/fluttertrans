const String htmlPage = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlutterTrans</title>
</head>
<body>
    <h1>Which strings to translate?</h1>
    <form id="stringForm">
        <div id="stringsContainer">
            <!-- Checkboxes will be dynamically added here -->
        </div>
        <button type="submit">Submit</button>
    </form>

    <script>
        const currentUrl = window.location.href;
        const stringsUrl = currentUrl + "strings";           // URL for fetching available strings
        const selectedStringsUrl = currentUrl + "selectedStrings"; // URL for fetching initially selected strings

        // Fetch the available strings
        fetch(stringsUrl)
            .then(response => response.json())
            .then(strings => {
                const container = document.getElementById('stringsContainer');
                
                // Fetch initially selected strings and check them
                fetch(selectedStringsUrl)
                    .then(response => response.json())
                    .then(initialSelection => {
                        strings.forEach(string => {
                            const checkbox = document.createElement('input');
                            checkbox.type = 'checkbox';
                            checkbox.name = 'strings';
                            checkbox.value = string;
                            checkbox.id = string;

                            // Automatically check the checkbox if it's part of the initial selection
                            if (initialSelection.includes(string)) {
                                checkbox.checked = true;
                            }

                            const label = document.createElement('label');
                            label.htmlFor = string;
                            label.textContent = string;

                            const lineBreak = document.createElement('br');

                            container.appendChild(checkbox);
                            container.appendChild(label);
                            container.appendChild(lineBreak);
                        });
                    })
                    .catch(error => console.error('Error fetching initial selection:', error));
            })
            .catch(error => console.error('Error fetching strings:', error));

        // Handle form submission
        document.getElementById('stringForm').addEventListener('submit', function (event) {
            event.preventDefault(); // Prevent the default form submission

            const selectedStrings = Array.from(document.querySelectorAll('input[name="strings"]:checked'))
                                        .map(input => input.value);

            // Send the selected strings as JSON via POST
            fetch(currentUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ selectedStrings })
            })
            .then(response => {
                if (response.ok) {
                    alert('Strings submitted successfully!');
                    window.close();
                } else {
                    alert('Failed to submit strings.');
                }
            })
            .catch(error => console.error('Error submitting strings:', error));
        });
    </script>
</body>
</html>
""";
