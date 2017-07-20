<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html> 
<body>
  <h2>Booking System</h2>
  <table style="float: right">
  <table border="2">
    <tr bgcolor="#ffa500">
      <th style="text-align:left">Start Time</th>
      <th style="text-align:left">End Time</th>
      <th style="text-align:left">Room</th>
    </tr>
    <xsl:for-each select="bookingsystem/bookings/date/bookingdetail">
    <tr>
      <td><xsl:value-of select="stime"/></td>
      <td><xsl:value-of select="etime"/></td>
      <td><xsl:value-of select="room"/></td>
    </tr>
    </xsl:for-each>
  </table>
  </table>
  <table style="float: right">
  <table border="2">
    <tr bgcolor="#ffa500">
      <th style="text-align:left">Equipment</th>
      <th style="text-align:left">Amount</th>
    </tr>
    <xsl:for-each select="bookingsystem/bookings/date/bookingdetail/uses">
    <tr>
	  <td><xsl:value-of select="eid"/></td>
      <td><xsl:value-of select="amount"/></td>
    </tr>
    </xsl:for-each>
  </table>
  </table>
  <p>
   There are a total of <xsl:value-of select="count(//bookingdetail)"/> booking(s) currently in the system
  </p>
  </body>
</html>
</xsl:template>
</xsl:stylesheet>