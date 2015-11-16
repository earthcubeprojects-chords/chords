---
layout: page
title: Concepts
---

<div class="container">
  <ul class="nav nav-pills">
    <li class="active"><a data-toggle="tab" href="#dashboard">Dashboard</a></li>
    <li><a data-toggle="tab" href="#data">Data</a></li>
    <li><a data-toggle="tab" href="#terms">Terminology</a></li>
  </ul>

  <div class="tab-content">
  
    <div id="terms" class="tab-pane">
    <p>Some of the terminology used in CHORDS is described here.</p>
    <table class = "table table-striped">
      <tbody>
        <tr>
          <td>Site</td>
          <td>A geographic location, which may host one or more instruments. It is the only place where 
             geographic coordinates are specified, so if you need to identify a unique location for an instrument, it
             must be assigned to a distinct site. </td>
        </tr>
        <tr>
          <td>Instrument</td>
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
          <td>Measurement</td>
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
          <td>Data URL</td>
          <td>The syntax used to submit and fetch data from the Portal. "Data URL" links, found on several
          pages of the Portal, take you to a page which provides examples for a particular instrument.</td>
        </tr>
        <tr>
          <td>Format</td>
          <td>URL extensions usually indicate the type of data that will be returned to a data request:
            <table>
              <tr><td>.csv</td><td> A comma separated data file.</td></tr>
              <tr><td>.jsf</td><td> A JSON file.</td></tr>
              <tr><td>.xml</td><td> An XML file.</td></tr>
              <tr><td>.json</td><td> A JSON string.</td></tr>
            </table>
          </td>
        </tr>
      </tbody>
    </table>
    </div>
    
    <div id="dashboard" class="tab-pane active">
      <p>
      The dashboard provides an overview of your system performance. It's the default
      view, accesible from the top level domain name, the CHORDS logo, and the 
      Dashboard link.
      </p>
      <ul>
        <li>A list of instrument links have status indicators which are green/red  indicating if a measurement 
        has been received within the nominal reporting interval for the instrument.</li>
        <li>The most recent measurement URL is shown in the green box.</li>
        <li>Three bar graphs show the number of measurements received for each instrument,
        over different time spans.</li>
      </ul>
      <img class="img-responsive" src="images/dashboard.png" alt="Dashboard">
    </div>
    
    <div id="data" class="tab-pane">
      <ul>
      <li>The Data page the Portal lets you download instrument data for selected days in
      various file formats.</li>
      <li>Links are also provided to "Data URLs" pages, which describe how to 
      construct a data request for each instrument.</li>
      <li>Remember that data can also be fetched directly by programs. You don't have
      to download files.</li>
      </li>
      <img class="img-responsive" src="images/data.png" alt="Data">
    </div>
  </div>
</div>
