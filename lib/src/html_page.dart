const String htmlPage = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlutterTrans</title>
    <link href="https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        /* General styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body, html {
            font-family: 'Quicksand', sans-serif;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: #f4f4f4;
        }

        .container {
            width: 100%;
            max-width: 800px;
            height: 100%;
            display: flex;
            flex-direction: column;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            position: relative;
        }

        h1 {
            margin: 0;
            font-weight: 600;
            font-size: 24px;
        }

        #submitButton {
            float: right;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            font-size: 16px;
            transition: background-color 0.3s;
        }

        #submitButton:hover {
            background-color: #45a049;
        }

        .controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
        }

        .action-buttons button {
            padding: 10px 20px;
            background-color: #008CBA;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            font-size: 16px;
            transition: background-color 0.3s, transform 0.2s;
        }

        .action-buttons button:hover {
            background-color: #007bb5;
            transform: scale(1.05);
        }

        .action-buttons button:active {
            transform: scale(0.98);
        }

        /* Container for the string checkboxes with scrolling */
        #stringsContainer {
            flex-grow: 1;
            max-height: calc(100vh - 160px); /* Adjust to fit buttons, padding, etc. */
            overflow-y: auto;
            border: 1px solid #ddd;
            padding: 10px;
            margin-top: 20px;
        }

        label {
            display: block;
            padding: 5px 0;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="controls">
            <div>
            <h1>FlutterTrans</h1>
            <p class="subtitle">* New strings which end with '.tr' are automatically selected.</p>
            </div>
            <button id="submitButton" type="submit" form="stringForm">Submit</button>
        </div>

        <div class="action-buttons">
            <button id="selectAllButton">Select All</button>
            <button id="deselectAllButton">Deselect All</button>
        </div>
        
        <form id="stringForm">
            <div id="stringsContainer">
                <!-- Checkboxes will be dynamically added here -->
            </div>
        </form>
    </div>

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
                    window.close();
                } else {
                    alert(`Failed to submit strings. Status code: \${response.status}.`);
                    console.error('Failed to submit strings:', response);
                }
            })
            .catch(error => console.error('Error submitting strings:', error));
        });
        
        document.getElementById('selectAllButton').addEventListener('click', function() {
            document.querySelectorAll('input[name="strings"]').forEach(checkbox => checkbox.checked = true);
        });

        document.getElementById('deselectAllButton').addEventListener('click', function() {
            document.querySelectorAll('input[name="strings"]').forEach(checkbox => checkbox.checked = false);
        });
    </script>

</body>
</html>
""";
