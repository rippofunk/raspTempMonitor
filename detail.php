<?php
//set a base temps for the initial reading of the temps, a starting point for the chart.
// each temp is logged independantly, so the mysql query only returns one of the four sensors as the starting point.
//this will start the other 3 at 50.
$desk=50;
$basement=50;
$outside=50;
$waterheater=50;
$pdostring = null;
try {
  $conn = new PDO('mysql:host=localhost;dbname=database', 'user', 'password');
  $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	$stmt = $conn->prepare('select * from temps where `timestamp` >= (CURDATE() - INTERVAL 2 DAY)  order by `timestamp`');
  $stmt->execute();
	while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
		$desk = $row['tempID'] == 'Desk' ? $row['tempF'] : $desk;
		$basement = $row['tempID'] == 'Basement' ? $row['tempF'] : $basement;
		$outside = $row['tempID'] == 'Outside' ? $row['tempF'] : $outside;
		$waterheater = $row['tempID'] == 'Water Heater' ? $row['tempF'] : $waterheater;
		$datehere = date('F j,Y H:i:s', strtotime($row['timestamp']) - 18000 ); // logging in utc, so subtract 5 hours from stamps
		$pdostring .=  '[new Date("'.$datehere .'"),'.$desk .','.$outside.','.$basement.','.$waterheater.'],';
  }

} catch(PDOException $e) {
  echo 'ERROR: ' . $e->getMessage();
}
?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      House temps last 2 days
    </title>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load('visualization', '1', {packages: ['corechart']});
    </script>
    <script type="text/javascript">
      function drawVisualization() {
        // Create and populate the data table.
        var data = google.visualization.arrayToDataTable([
          ['Timestamp', 'Desk','Outside','Basement','Water Heater'],
<?php echo rtrim($pdostring,',');?>
        ]);
        // Create and draw the visualization.
        new google.visualization.LineChart(document.getElementById('visualization')).
            draw(data, {curveType: "function",
                        width: 1200, height: 400,
                        vAxis: {maxValue: 10}}
                );
      }
      google.setOnLoadCallback(drawVisualization);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <div id="visualization" style="width: 1200px; height: 400px;"></div>
		<div id="visualization2" style="width: 1200px; height: 400px;"></div>
  </body>
</html>
