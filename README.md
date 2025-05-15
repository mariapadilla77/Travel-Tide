# Travel-Tide
E-booking startup TravelTide is a hot new player in the online travel industry. It has experienced steady growth since it was founded at the tail end of the COVID-19 pandemic (2021-04) on the strength of its data aggregation and search technology, which is best in class. Feedback from the customers has shown - and industry analysts agree - that TravelTide customers have access to the largest travel inventory in the e-booking space!

## Objective 
Design and execute a personalized rewards program that keeps customers returning to the TravelTide platform.

## Methodolgy

### EDA - Exploring the Data:
To explore and analyze the dataset, Structured Query Language (SQL) was employed as the primary tool for data extraction, transformation, and aggregation. The process began by querying raw tables to understand data structures, identify key relationships, and filter relevant records. 

### Feature Engineering - Devising Metrics:
SQL was used to define and calculate key performance metrics essential to the project's analytical objectives. This involved creating derived fields using conditional logic (CASE WHEN), aggregating measures with functions such as COUNT(), AVG(), and SUM(), and applying GROUP BY clauses to evaluate performance across different dimensions (e.g., user level, time periods, or product categories). Where applicable, window functions like RANK() and PERCENT_RANK() were employed to normalize and compare user behavior or outcomes. These custom metrics provided a structured and repeatable framework for measuring engagement, performance, and trends, forming the foundation for subsequent ranking, segmentation, and visualization tasks.

### Customer Segmentation - Grouping the Customers:
In the third stage of the project, Tableau was utilized to develop dynamic customer segmentations based on behavioral and performance metrics derived from prior SQL analysis. Using calculated fields, ranking logic, and set membership, customers were grouped into distinct segments reflecting patterns such as activity level, engagement, or metric-based performance. Tableau’s interactive features—such as parameter controls, filters, and set actions—enabled flexible exploration of these segments, allowing for quick comparisons and visual analysis of segment-specific trends. This visual segmentation approach supported strategic decision-making by highlighting key differences between customer groups in a clear, data-driven manner.

## Connect to the TravelTide database
postgres://Test:bQNxVzJL4g6u@ep-noisy-flower-846766.us-east-2.aws.neon.tech/TravelTide

