<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Weather Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.0.2/dist/tailwind.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/weather-design.css">
</head>
<body class="text-white bg-gray-800 bg-opacity-80">
  <div class="container mx-auto p-4">
    <div class="header">
        <h1 class="header">Weather Dashboard</h1>
        <p class="title">View historical weather data for a specific location and date range.</p>
    </div>
    <form action="weather-data.jsp" method="post">
      <div class="square">
        <div class="grid grid-cols-2 gap-4 mb-6">
          <div class="text1">
            <label class="block text-black font-medium">Latitude</label>
            <input type="number" id="latitude" class="w-full border rounded p-2" placeholder="Enter latitude" required>
          </div>
          <div class="text2">
            <label class="block text-black font-medium">Longitude</label>
            <input type="number" id="longitude" class="w-full border rounded p-2" placeholder="Enter longitude" required>
          </div>
          <div class="text3">
            <label class="block text-sm font-medium">Start Date</label>
            <input type="date" id="start-date" class="w-full border rounded p-2" required>
            <img alt="calendar" src="image/calendar.png" onclick="document.getElementById('start-date').focus()">
          </div>
          <div class="text4">
            <label class="block text-sm font-medium">End Date</label>
            <input type="date" id="end-date" class="w-full border rounded p-2" required>
            <img alt="calendar" src="image/calendar.png" onclick="document.getElementById('end-date').focus()">
          </div>
        </div>
        <button type="button" id="fetch-data" class="w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600">Fetch Weather Data</button>
      </div>
    </form>
  </div>
  <div id="loading" class="text-center mt-4 hidden">Loading...</div>
  <canvas id="weather-chart" class="my-6"></canvas>
  <div>
    <table>
      <thead>
        <tr>
          <th class="p-2 text-left">Date</th>
          <th class="p-2 text-left">Max Temp (°C)</th>
          <th class="p-2 text-left">Min Temp (°C)</th>
          <th class="p-2 text-left">Mean Temp (°C)</th>
          <th class="p-2 text-left">Max Apparent Temp (°C)</th>
          <th class="p-2 text-left">Min Apparent Temp (°C)</th>
          <th class="p-2 text-left">Mean Apparent Temp (°C)</th>
        </tr>
      </thead>
      <tbody id="weather-table"></tbody>
    </table>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="js/weather-script1.js"></script>
  <script src="js/weather-script2.js"></script>
  <script>
    const fetchDataBtn = document.getElementById("fetch-data");
    const weatherTable = document.getElementById("weather-table");
    const loading = document.getElementById("loading");
    const weatherChart = document.getElementById("weather-chart").getContext("2d");
    let chart;

    fetchDataBtn.addEventListener("click", async () => {
      const latitude = document.getElementById("latitude").value;
      const longitude = document.getElementById("longitude").value;
      const startDate = document.getElementById("start-date").value;
      const endDate = document.getElementById("end-date").value;

      // Input validation
      if (!latitude || !longitude || !startDate || !endDate) {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "Please fill all fields are required and before fetching the data",
        });
        return;
      }

      if (isNaN(latitude) || isNaN(longitude)) {
        Swal.fire({
          icon: "error",
          title: "Invalid Latitude/Longitude",
          text: "Please enter valid Numeric Values for Latitude and Longitude",
        });
        return;
      }

      if (new Date(startDate) > new Date(endDate)) {
        Swal.fire({
          icon: "error",
          title: "Invalid Date Range",
          text: "Start date cannot be later than the End date",
        });
        return;
      }

      loading.classList.remove("hidden");

      try {
        const response = await fetch(
          `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&start_date=${startDate}&end_date=${endDate}&daily=temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,apparent_temperature_min,apparent_temperature_mean&timezone=auto`
        );
        
        if (!response.ok) {
          throw new Error("Failed to fetch data");
        }

        const data = await response.json();

        if (chart) chart.destroy();

        const labels = data.daily.time;
        const maxTemp = data.daily.temperature_2m_max;
        const minTemp = data.daily.temperature_2m_min;
        const meanTemp = data.daily.temperature_2m_mean;
        const maxAppTemp = data.daily.apparent_temperature_max;
        const minAppTemp = data.daily.apparent_temperature_min;
        const meanAppTemp = data.daily.apparent_temperature_mean;

        // Update Chart
        chart = new Chart(weatherChart, {
          type: "line",
          data: {
            labels,
            datasets: [
              { label: "Max Temp (°C)", data: maxTemp, borderColor: "red", fill: false },
              { label: "Min Temp (°C)", data: minTemp, borderColor: "blue", fill: false },
              { label: "Mean Temp (°C)", data: meanTemp, borderColor: "green", fill: false },
              { label: "Max Apparent Temp (°C)", data: maxAppTemp, borderColor: "orange", fill: false },
              { label: "Min Apparent Temp (°C)", data: minAppTemp, borderColor: "purple", fill: false },
              { label: "Mean Apparent Temp (°C)", data: meanAppTemp, borderColor: "pink", fill: false },
            ],
          },
        });

        // Update Table
        weatherTable.innerHTML = labels
          .map(
            (date, i) => `
            <tr>
              <td class="p-2 border">${date}</td>
              <td class="p-2 border">${maxTemp[i]}</td>
              <td class="p-2 border">${minTemp[i]}</td>
              <td class="p-2 border">${meanTemp[i]}</td>
              <td class="p-2 border">${maxAppTemp[i]}</td>
              <td class="p-2 border">${minAppTemp[i]}</td>
              <td class="p-2 border">${meanAppTemp[i]}</td>
            </tr>
          `
          )
          .join("");

        Swal.fire({
          icon: "success",
          title: "Success",
          text: "Weather Data Successfully Retrieved and Displayed",
        });
      } catch (error) {
        Swal.fire({
          icon: "error",
          title: "Error",
          text: "Failed to fetch data. Please check your inputs or try again later",
        });
      } finally {
        loading.classList.add("hidden");
      }
    });
  </script>
</body>
</html>
