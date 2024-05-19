# INDAQ - India Air Quality

Monitor daily air quality updates to index, level, and prominent pollutant across different cities in India, sourced from the daily bulletin report of Central Pollution Control Board, Government of India.

Air Quality is a crucial tool to communicate the quality of air in a given area, indicating the level of pollution and its potential impact on public health. It is calculated based on the concentrations of eight prominent pollutants, namely, Particulate Matter (PM<sub>10</sub> and PM<sub>2.5</sub>), Nitrogen Dioxide (NO<sub>2</sub>), Sulfur Dioxide (SO<sub>2</sub>), Carbon Monoxide (CO), Ozone (O<sub>3</sub>), Ammonia (NH<sub>3</sub>), and Lead (Pb). The estimation procedure involves continuous monitoring of these pollutants using a network of air quality monitoring stations across the country. Each pollutant's concentration is measured and then converted into a normalized index value using standard formulas and breakpoint tables provided by the Central Pollution Control Board (CPCB). The highest index value among the pollutants determines the overall AQI for that location. This value is then categorized into six levels—ranging from 'Good' to 'Severe'—to convey the health implications effectively to the public, aiding in the adoption of necessary precautio nary measures and policy decisions aimed at improving air quality.

<div class="l-page">
  <iframe
    src="{{ '/assets/plotly/index.html' | relative_url }}"
    frameborder="0"
    scrolling="no"
    height="455"
    width="800"
  ></iframe>
</div>

**Figure.** Air quality index across different cities in India

The Air Quality Index (AQI) is given by:

\begin{equation}
\label{eq:aqi}
\text{AQI} = \max(\text{AQI}_ \text{PM2.5}, \text{AQI}_ \text{PM10}, \text{AQI}_ \text{NO2}, \text{AQI}_ \text{SO2}, \text{AQI}_ \text{O3}, \text{AQI}_ \text{NH3})
\end{equation}

\begin{equation}
\label{eq:aqip}
\text{AQI}_ \text{p} = \frac{(\text{I}_ \text{high} - \text{I}_ \text{low})}{(\text{C}_ \text{high} - \text{C}_ \text{low})} \times (\text{C}_ \text{p} - \text{C}_ \text{low}) + \text{I}_ \text{low}
\end{equation}

where:

- $$ \text{AQI}_ \text{p} $$ is the AQI for pollutant $$ p $$.
- $$ \text{C}_ \text{p} $$ is the concentration of pollutant $$ p $$.
- $$ \text{C}_ \text{high} $$ and $$ \text{C}_ \text{low} $$ are the concentration breakpoints that bracket $$ \text{C}_ \text{p} $$.
- $$ \text{I}_ \text{high} $$ and $$ \text{I}_ \text{low} $$ are the AQI breakpoints corresponding to $$ \text{C}_ \text{high} $$ and $$ \text{C}_ \text{low} $$.

<div class="l-page">
  <iframe
    src="{{ '/assets/plotly/level.html' | relative_url }}"
    frameborder="0"
    scrolling="no"
    height="605"
    width="450"
  ></iframe>
</div>

**Figure.** Air quality level across different cities in India

**Table.** Air quality index and level and associated pollutant concenrtation range

<table
  id="table"
  data-toggle="table"
  data-url="{{ '/assets/json/airquality.json' | relative_url }}"
>
  <thead>
    <tr>
      <th data-field="AQI Category">AQI Category</th>
      <th data-field="AQI">AQI</th>
      <th data-field="PM10">PM<sub>10</sub></th>
      <th data-field="PM2.5">PM<sub>2.5</sub></th>
      <th data-field="NO2">NO<sub>2</sub></th>
      <th data-field="O3">O<sub>3</sub></th>
      <th data-field="CO">CO</th>
      <th data-field="SO2">SO<sub>2</sub></th>
      <th data-field="NH3">NH<sub>3</sub></th>
      <th data-field="Pb">Pb</th>
    </tr>
  </thead>
</table>
<sup>CO in mg/m<sup>3</sup> and other pollutants in μg/m<sup>3</sup>; 24-hourly average values for PM<sub>10</sub>, PM<sub>2.5</sub>, NO<sub>2</sub>,SO<sub>2</sub>, NH<sub>3</sub>, and Pb, and 8-hourly values for CO and O<sub>3</sub>.</sup>

<div class="l-page">
  <iframe
    src="{{ '/assets/plotly/pollutant.html' | relative_url }}"
    frameborder="0"
    scrolling="no"
    height="605"
    width="450"
  ></iframe>
</div>

**Figure.** Prominent pollutant across different cities in India
