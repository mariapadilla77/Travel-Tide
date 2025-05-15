
WITH 
--Joined tables to have all information available together. 
--Calculated correct number of nights in hotels table.
--Filtered sessions no more than 01-04 for a more accurate analysis
joined_tables AS (
  SELECT 
  	u.user_id as u_id,
  	s.trip_id as trip_id_sessions,
  	f.trip_id as trip_id_flights,
  	h.trip_id as trip_id_hotel,
  	*,
    CASE
      WHEN check_out_time::date - check_in_time::date <1 THEN 1
      ELSE check_out_time::date - check_in_time::date
    END as nights_new,
  	CASE when rooms = 0 THEN 1 ELSE rooms END as new_rooms,
  	COALESCE(hotel_discount_amount, 0) AS new_hotel_discount,
  	COALESCE(flight_discount_amount,0) AS new_flight_discount
  FROM sessions s
  LEFT JOIN users u ON s.user_id = u.user_id
  LEFT JOIN hotels h ON s.trip_id = h.trip_id
  LEFT JOIN flights f ON s.trip_id = f.trip_id 	
  WHERE s.session_start >= '2023-01-04' 
),
--User Level table created to have all information based ona user level granularity.
--Filtered only users with more than 7 sessions.
--Calculation of age ranges.
user_level AS (
  SELECT
  	u_id,
  	CASE WHEN 
			EXTRACT(year from age('2023-07-28', birthdate)) < 18 THEN 'Under 18'
			WHEN EXTRACT(year from age('2023-07-28', birthdate)) < 25 THEN '18-25'
			WHEN EXTRACT(year from age('2023-07-28', birthdate)) < 35 THEN '25-35'
			WHEN EXTRACT(year from age('2023-07-28', birthdate)) < 45 THEN '35-45'
			WHEN EXTRACT(year from age('2023-07-28', birthdate)) < 55 THEN '45-55'
			WHEN EXTRACT(year from age('2023-07-28', birthdate)) < 65 THEN '55-65'
			ELSE '65+' 
		END AS user_age
  FROM joined_tables
  GROUP BY u_id, birthdate
  HAVING COUNT(session_id) > 7 
), 
--Calculated average for numerous metrics, taking non cancellated flights. 
trip_metrics AS (
  SELECT
  	u_id, 
  	AVG(nights_new) as avg_nights,
  	AVG(checked_bags) as avg_bags,
  	AVG(seats) as avg_seats, 
  	SUM(seats) as total_seats,
  	SUM(new_rooms) as count_rooms,
  	SUM((1-new_flight_discount) * base_fare_usd) AS money_spent_flight,
  	SUM(hotel_per_room_usd * new_rooms * nights_new * (1 - new_hotel_discount)) as money_spent_hotel,
  	AVG(haversine_distance(
  				home_airport_lat,
  				home_airport_lon,
  				destination_airport_lat,
  				destination_airport_lon
  			)) as avg_km_flown,
		COUNT(DISTINCT trip_id_sessions) as num_trips,
  	COUNT(CASE WHEN flight_discount_amount is not null 
          OR hotel_discount_amount is not null
          THEN 1 
  				END) AS trips_with_discount,
		SUM (CASE WHEN flight_booked = TRUE 
         THEN 1 
         END) AS num_flights_booked,
  	COUNT(distinct trip_id_flights) as num_flights
FROM joined_tables
  GROUP BY u_id
    ),
--Calculation of metrics based on sessions table.    
session_metrics AS (
	SELECT
  	u_id,
		COUNT(DISTINCT session_id) as total_number_session,
		AVG(page_clicks) as avg_clicks,
  	AVG(session_end - session_start) as avg_session_duration
	FROM joined_tables
  GROUP BY u_id
)


--Selection of final table. 
SELECT 
	ul.u_id, 
  total_number_session,
	sign_up_date,
  EXTRACT(EPOCH FROM avg_session_duration::TIME) AS seconds,
  user_age,
	gender, 
  has_children, 
  married, 
  home_country,
  home_city,
  avg_seats,
  sum(new_rooms) as sum_of_rooms,
  sum(COALESCE(nights_new,0)) as number_of_nights,
  num_trips,
  num_flights_booked,
  num_flights,
  trips_with_discount,
  COALESCE(money_spent_flight,0) AS money_spent_flight,
  COALESCE(money_spent_hotel,0) AS money_spent_hotel,
  COALESCE(avg_km_flown,0) AS avg_km_flown,
  cancellation
FROM joined_tables jt
	JOIN user_level ul ON jt.u_id = ul.u_id
	LEFT JOIN trip_metrics tm ON tm.u_id = jt.u_id
	LEFT JOIN session_metrics sm ON sm.u_id = jt.u_id
where cancellation IS false 
GROUP BY
ul.u_id, 
  total_number_session,
	sign_up_date,
  avg_session_duration,
  user_age,
	gender, 
  has_children, 
  married, 
  home_country,
  home_city,
  num_trips,
  num_flights_booked,
  num_flights,
  trips_with_discount,
  money_spent_hotel,
  money_spent_flight,
  avg_km_flown,
  cancellation,
  avg_seats
