---
layout: page
title: CHORDS Concepts
---

## Terminology

<div class="container">
  <table class = "table table-striped">
    <tbody>
      <tr>
        <td>Sites</td>
        <td>A geographic location, which may host one or more instruments. It is the only place where 
           coordinates are specified, so if you need to identify a unique location for an instrument, it
           must be assigned to a distinct site. </td>
      </tr>
      <tr>
        <td>Instruments</td>
        <td>A source of related measurements. Typically it is one device, but you can designate multiple
        devices as a single instrument, or you can divide the measurements from a single device among
        multiple instruments, if this results in a more appropriate data organization. </td>
      </tr>
      <tr>
        <td>Variable</td>
        <td>A particular measurement made by an instrument, such as such as temperature, or pH.
        Variables have <em>Short Names</em></td>
      </tr>
      <tr>
        <td>Measurements</td>
        <td>A single observation of a Variable. Measurements are assigned to 
        instruments, and each one has an associated time of observation. Typically, multiple
        measurements for the same instrument are submitted together, with a common time tag.</td>
      </tr>
      <tr>
        <td>Short Name</td>
        <td>A compact identifier for a variable, which is used to represent it in a URL. This is done
        to keep URLs from becomming unreasonably long. For example, the short name for temperature
        might be assigned as <em>t</em>, pressure as <em>p</em>, etc. The short name should be as short as possible, but
        still be useful for identification.</td>
      </tr>
      <tr>
        <td>Formats</td>
        <td>URL extensions usually indicate the type of data that will be returned to a data request:
          <table>
            <tr><td>.csv</td><td> A comma separated data file.</td></tr>
            <tr><td>.jsf</td><td> A JSON file.</td></tr>
            <tr><td>.json</td><td> A JSON string.</td></tr>
          </table>
        </td>
      </tr>
    </tbody>
  </table>
</div>
