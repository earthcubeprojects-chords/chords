---
layout: page
title: CHORDS Concepts
---

<div class="container">
  <table class = "table table-striped">
    <thead>
      <tr>
        <th>Concept</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Sites</td>
        <td>A geographic location, which may host one or more instruments. It is the only place where 
           coordinates are specified, so if you need to identify a unique location for an instrument, it
           must be assigned to a specific site. </td>
      </tr>
      <tr>
        <td>Instruments</td>
        <td>A source of related measurements. Typically it is one device, but you can designate multiple
        devices as a single instruments, or you can assign the measurements from a single device to
        multiple instruments, if this gives a more appropriate data organization. </td>
      </tr>
      <tr>
        <td>Measurements</td>
        <td>A single observed value, such as temperature, or pH. Measurements are assigned to 
        instruments, and each one has an associate time of observation. Typically, multiple
        measurements for the same instrument are submitted together, with a common time tag.</td>
      </tr>
      <tr>
        <td>Formats</td>
        <td>URL extensions usually indicate the type of data that will be returned to a data request:
          <table>
            <tr><td>.csv</td><td>A comma separated data file.</td></tr>
            <tr><td>.jsf</td><td>A JSON file.</td></tr>
            <tr><td>.json</td><td>A A JSON string</td></tr>
          </table>
        </td>
      </tr>
    </tbody>
  </table>
</div>
