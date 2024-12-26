
  // Snowflake generation
  const createSnowflake = () => {
    const snowflake = document.createElement('div');
    snowflake.classList.add('snowflake');
    snowflake.innerHTML = '.'; // Snowflake symbol
    snowflake.style.left = `${Math.random() * 100}%`; // Random horizontal position
    snowflake.style.animationDuration = `${Math.random() * 10 + 5}s`; // Random fall speed
    snowflake.style.fontSize = `${Math.random() * 10 + 10}px`; // Random size
    document.body.appendChild(snowflake);

    // Remove snowflake after animation completes
    snowflake.addEventListener('animationend', () => {
      snowflake.remove();
    });
  };

  // Create snowflakes at intervals
  setInterval(createSnowflake, 200); // Create a snowflake every 100ms
