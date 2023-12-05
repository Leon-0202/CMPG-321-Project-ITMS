CREATE DATABASE CMPG321_ProjectPhase02;

/*================================================
DROP TABLES
================================================*/
USE CMPG321_ProjectPhase02;

DROP TABLE ROAD_SECTION_IN_ROUTE;
DROP TABLE ROAD_SECTION_IN_INTERSECTION;
DROP TABLE ROAD_IN_DISTRICT;
DROP TABLE BUS_SECTION;
DROP TABLE PEDESTRIAN_SECTION;
DROP TABLE CYCLE_SECTION;
DROP TABLE VEHICLE_SECTION;
DROP TABLE STREET_VIEW;
DROP TABLE SATELLITE_VIEW;
DROP TABLE ROAD_SURFACE;
DROP TABLE VEHICLE;
DROP TABLE [ROUTE];
DROP TABLE INCIDENT_IN_ROAD_SECTION;
DROP TABLE [USER];
DROP TABLE INCIDENT_TYPE;
DROP TABLE TRAFFIC_LIGHT;
DROP TABLE INTERSECTION;
DROP TABLE CROSSING;
DROP TABLE WEATHER_IN_DISTRICT;
DROP TABLE DISTRICT;
DROP TABLE CAPTURED_DATA;
DROP TABLE [DATA_SOURCE];
DROP TABLE TRAFFIC_FLOW;
DROP TABLE LOCATION_OF_INTEREST;
DROP TABLE USER_ROLE;
DROP TABLE INTERSECTION_TYPE;
DROP TABLE CROSSING_TYPE;
DROP TABLE WEATHER_CONDITION;
DROP TABLE DATA_SOURCE_TYPE;
DROP TABLE CONGESTION_LEVEL;
DROP TABLE LOCATION_TYPE;
DROP TABLE ROAD_SECTION;
DROP TABLE ROAD;

/*================================================
CREATE TABLES
================================================*/
USE CMPG321_ProjectPhase02;

-- Strong Entities
/*
Table LOCATION_TYPE: To define types/categories of locations.
*/
CREATE TABLE LOCATION_TYPE (
    LocationTypeID INT PRIMARY KEY,
    LocationType VARCHAR(50)
);

/*
Table CONGESTION_LEVEL: To categorize congestion levels with names and descriptions.
*/
CREATE TABLE CONGESTION_LEVEL (
    CongestionLevel_ID INT PRIMARY KEY,
    CongestionLevelName VARCHAR(50),
    CongestionLevelDescription VARCHAR(100)
);

/*
Table DATA_SOURCE_TYPE: To define types/categories of data sources.
*/
CREATE TABLE DATA_SOURCE_TYPE (
    DataSourceTypeID INT PRIMARY KEY,
    DataSourceTypeName VARCHAR(50),
    DataSourceTypeDescription VARCHAR(100)
);

/*
Table WEATHER_CONDITION: To categorize weather conditions.
*/
CREATE TABLE WEATHER_CONDITION (
    WeatherConditionID INT PRIMARY KEY,
    WeatherType VARCHAR(50),
    WeatherDescription VARCHAR(100)
);

/*
Table CROSSING_TYPE: To define types/categories of crossings.
*/
CREATE TABLE CROSSING_TYPE (
    CrossingTypeID INT PRIMARY KEY,
    CrossingTypeDescription VARCHAR(100)
);

/*
Table INTERSECTION_TYPE: To define types/categories of intersections.
*/
CREATE TABLE INTERSECTION_TYPE (
    IntersectionTypeID INT PRIMARY KEY,
    IntersectionDescription VARCHAR(100)
);

/*
Table USER_ROLE: To define the roles/categories of users.
*/
CREATE TABLE USER_ROLE (
    UserRoleID INT PRIMARY KEY,
    UserRoleTitle VARCHAR(50),
    UserDescription VARCHAR(100)
);

/*
Table ROAD: To define roads by name.
*/
CREATE TABLE ROAD (
    RoadID INT PRIMARY KEY,
    RoadName NVARCHAR(50)
);

/*
Table ROAD_SECTION: To define road sections with type, length, width, direction, and coordinates.
*/
CREATE TABLE ROAD_SECTION (
    RoadSectionID INT PRIMARY KEY,
    RoadSectionType CHAR CHECK (RoadSectionType IN ('V', 'C', 'P', 'B')) NOT NULL,
	-- RoadSectionType determines which type of road it is by making it a member of one of its subtypes.
	-- Due to the total completeness of the supertype/subtype hierarchy, a value must be provided and can't be NULL.
	-- The value must match the corresponding value of one of its subtypes.
    RoadSectionLength DECIMAL (9, 1),
    RoadSectionWidth DECIMAL (9, 1),
    RoadID INT NOT NULL, -- A ROAD_SECTION must be associated with a ROAD.
    RoadDirection VARCHAR(20),
    RoadSectionCoordinates1 GEOGRAPHY,
    RoadSectionCoordinates2 GEOGRAPHY,

	-- Creates a relationship between ROAD_SECTION and ROAD
    CONSTRAINT FK_ROAD_CONSISTS_OF_ROAD_SECTION FOREIGN KEY (RoadID) REFERENCES ROAD(RoadID)
);


/*
Table LOCATION_OF_INTEREST: To store information about various locations of interest, 
including their types and related road sections.
*/
CREATE TABLE LOCATION_OF_INTEREST (
    LocationID INT PRIMARY KEY,
    LocationName VARCHAR(50),
    LocationDescription VARCHAR(100),
    LocationTypeID INT NOT NULL, -- A LOCATION_OF_INTEREST must be associated with a LOCATION_TYPE.
    LocationCoordinates GEOGRAPHY,
    RoadSectionID INT NOT NULL, -- A LOCATION_OF_INTEREST must be associated with a ROAD_SECTION.

	-- Creates a relationship between LOCATION_OF_INTEREST and LOCATION_TYPE
    CONSTRAINT FK_LOCATION_OF_INTEREST_IS_OF_TYPE FOREIGN KEY (LocationTypeID) REFERENCES LOCATION_TYPE(LocationTypeID),

	-- Creates a relationship between LOCATION_OF_INTEREST and ROAD_SECTION
    CONSTRAINT FK_LOCATION_OF_INTEREST_LOCATED_IN_ROAD_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);

/*
Table TRAFFIC_FLOW: To capture and store traffic flow data, including speed, 
vehicle count, and congestion levels for road sections.
*/
CREATE TABLE TRAFFIC_FLOW (
    TrafficFlowID INT PRIMARY KEY,
    RoadSectionID INT NOT NULL, -- A TRAFFIC_FLOW must be associated with a ROAD_SECTION.
    TrafficFlowDateTime DATETIME,
    AvgVehicleSpeed DECIMAL(4, 1) CHECK (AvgVehicleSpeed BETWEEN 0.0 AND 999.9),	-- The average speed of the vehicles in a road section must be positive
																					-- and below the practical limit of a 1000km/h.
    NoOfVehicles INT CHECK (NoOfVehicles >= 0),	-- The amount of vehicles present in a road section can't be negative.
    CongestionLevel_ID INT NOT NULL, -- A TRAFFIC_FLOW must be associated with a CONGESTION_LEVEL.

	-- Creates a relationship between TRAFFIC_FLOW and ROAD_SECTION
    CONSTRAINT FK_TRAFFIC_FLOW_PRESENT_IN_ROAD_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID),

	-- Creates a relationship between TRAFFIC_FLOW and CONGESTION_LEVEL
    CONSTRAINT FK_CONGESTION_LEVEL_PRESENT_IN_TRAFFIC_FLOW FOREIGN KEY (CongestionLevel_ID) REFERENCES CONGESTION_LEVEL(CongestionLevel_ID)
);

/*
Table DATA_SOURCE: To manage and record the status of data sources, including installation date and types
*/
CREATE TABLE [DATA_SOURCE] (
    DataSourceID INT PRIMARY KEY,
    RoadSectionID INT NOT NULL, -- A DATA_SOURCE must be associated with a ROAD_SECTION.
    DateInstalled DATETIME,
    DataSourceTypeID INT NOT NULL, -- A DATA_SOURCE must be associated with a DATA_SOURCE_TYPE.

	-- Creates a relationship between DATA_SOURCE and ROAD_SECTION
    CONSTRAINT FK_DATA_SOURCE_LOCATED_IN_ROAD_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID),

	-- Creates a relationship between DATA_SOURCE and DATA_SOURCE_TYPE
    CONSTRAINT FK_DATA_SOURCE_IS_OF_TYPE_DATA_SOURCE_TYPE FOREIGN KEY (DataSourceTypeID) REFERENCES DATA_SOURCE_TYPE(DataSourceTypeID)
);

/*
Table CAPTURED_DATA: To store the data captured by data sources, including vehicle presence, speed, and timestamp.
*/
CREATE TABLE CAPTURED_DATA (
    DataID INT PRIMARY KEY,
    DataSourceID INT NOT NULL, -- A CAPTURED_DATA must be associated with a DATA_SOURCE.
    CaptureDateTime DATETIME,
    VehiclePresenceCount INT CHECK (VehiclePresenceCount >= 0),	-- The amount of vehicles present in a road section can't be negative.
    VehicleSpeed DECIMAL (4, 1) CHECK (VehicleSpeed BETWEEN 0.0 AND 999.9),	-- The speed of a vehicle must be positive
																			-- and below the practical limit of a 1000km/h.

	-- Creates a relationship between CAPTURED_DATA and DATA_SOURCE
    CONSTRAINT FK_CAPTURED_DATA_CAPTURED_BY_DATA_SOURCE FOREIGN KEY (DataSourceID) REFERENCES [DATA_SOURCE](DataSourceID)
);

/*
Table DISTRICT: To define districts with names and area codes.
*/
CREATE TABLE DISTRICT (
    DistrictID INT PRIMARY KEY,
    DistrictName NVARCHAR(50),
    DistrictAreaCode VARCHAR(4)
);

/*
Table WEATHER_IN_DISTRICT: To associate weather conditions with specific districts and time periods.
*/
CREATE TABLE WEATHER_IN_DISTRICT (
    WeatherInDistrictID INT PRIMARY KEY,
    DistrictID INT NOT NULL, -- A WEATHER_IN_DISTRICT must be associated with a DISTRICT.
    WeatherConditionID INT NOT NULL, -- A WEATHER_IN_DISTRICT must be associated with a WEATHER_CONDITION.
    WeatherStartDateTime DATETIME,
    WeatherEndDateTime DATETIME,

	-- Creates a relationship between WEATHER_IN_DISTRICT and DISTRICT
    CONSTRAINT FK_DISTRICT_EXPERIENCES_WEATHER_IN_DISTRICT FOREIGN KEY (DistrictID) REFERENCES DISTRICT(DistrictID),

	-- Creates a relationship between WEATHER_IN_DISTRICT and WEATHER_CONDITION
    CONSTRAINT FK_WEATHER_CONDITION_OCCURS_IN_WEATHER_IN_DISTRICT FOREIGN KEY (WeatherConditionID) REFERENCES WEATHER_CONDITION(WeatherConditionID)
);

/*
Table CROSSING: To define road crossings and associate them with road sections.
*/
CREATE TABLE CROSSING (
    CrossingID INT PRIMARY KEY,
    RoadSectionID INT NOT NULL, -- A CROSSING must be associated with a ROAD_SECTION.
    CrossingTypeID INT NOT NULL, -- A CROSSING must be associated with a CROSSING_TYPE.
	CrossingCoordinates GEOGRAPHY,

	-- Creates a relationship between CROSSING and ROAD_SECTION
    CONSTRAINT FK_CROSSING_LOCATED_IN_ROAD_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID),

	-- Creates a relationship between CROSSING and CROSSING_TYPE
    CONSTRAINT FK_CROSSING_IS_OF_TYPE_CROSSING_TYPE FOREIGN KEY (CrossingTypeID) REFERENCES CROSSING_TYPE(CrossingTypeID)
);

/*
Table INTERSECTION: To define intersections and associate them with types.
*/
CREATE TABLE INTERSECTION (
    IntersectionID INT PRIMARY KEY,
    IntersectionTypeID INT NOT NULL, -- An INTERSECTION must be associated with an INTERSECTION_TYPE.
    IntersectionCoordinates GEOGRAPHY,

	-- Creates a relationship between INTERSECTION and INTERSECTION_TYPE
    CONSTRAINT FK_INTERSECTION_IS_OF_TYPE_INTERSECTION_TYPE FOREIGN KEY (IntersectionTypeID) REFERENCES INTERSECTION_TYPE(IntersectionTypeID)
);

/*
Table TRAFFIC_LIGHT: To record the status of traffic lights at intersections.
*/
CREATE TABLE TRAFFIC_LIGHT (
    TrafficLightID INT PRIMARY KEY,
    IntersectionID INT NOT NULL, -- A TRAFFIC_LIGHT must be associated with an INTERSECTION.
    Operational BIT,
    Pedestrian_Crossing BIT,
    DirectionalArrows BIT,

	-- Creates a relationship between TRAFFIC_LIGHT and INTERSECTION
    CONSTRAINT FK_TRAFFIC_LIGHT_LOCATED_IN_INTERSECTION FOREIGN KEY (IntersectionID) REFERENCES INTERSECTION(IntersectionID)
);

/*
Table INCIDENT_TYPE: To define types/categories of intersections.
*/
CREATE TABLE INCIDENT_TYPE (
    IncidentTypeID INT PRIMARY KEY,
    IncidentTypeName VARCHAR(50),
    IncidentSeverity INT CHECK (IncidentSeverity BETWEEN 1 AND 5)
	-- Each type of incident is assigned a severity on a scale of 1 to 5.
	-- This value represents the impact that the incident will have on traffic flow, 
	-- with the highest value being the most severe.
);

/*
Table USER: To manage and store user information, including name, contact, and the access role level they have, 
to determine the amount of information that will be accessible to them from the database.
*/
CREATE TABLE [USER] (
    UserID INT PRIMARY KEY,
    UserIDNumber VARCHAR(13),
    UserLastName NVARCHAR(50),
    UserFirstName NVARCHAR(50),
    UserPhoneNo VARCHAR(15),
    UserEmail NVARCHAR(64),
    UserRoleID INT NOT NULL, -- A USER must be associated with a USER_ROLE.

	-- Creates a relationship between USER and USER_ROLE
    CONSTRAINT FK_USER_ASSUMES_USER_ROLE FOREIGN KEY (UserRoleID) REFERENCES USER_ROLE(UserRoleID)
);

/*
Table INCIDENT_IN_ROAD_SECTION: To record and keep track of incidents, including type, description, 
start and end times, and the user ID of the user that reported the incident.
*/
CREATE TABLE INCIDENT_IN_ROAD_SECTION (
    IncidentInRoadSectionID INT PRIMARY KEY,
    IncidentTypeID INT NOT NULL, -- A INCIDENT_IN_ROAD_SECTION must be associated with an INCIDENT_TYPE.
    RoadSectionID INT NOT NULL, -- A INCIDENT_IN_ROAD_SECTION must be associated with a ROAD_SECTION.
    IncidentDescription VARCHAR(100),
    IncidentStartDateTime DATETIME,
    IncidentEndDateTime DATETIME,
    UserID INT NOT NULL, -- A INCIDENT_IN_ROAD_SECTION must be associated with a USER.

	-- Creates a relationship between INCIDENT_IN_ROAD_SECTION and INCIDENT_TYPE
    CONSTRAINT FK_INCIDENT_TYPE_OCCURS_IN_INCIDENT_IN_ROAD_SECTION FOREIGN KEY (IncidentTypeID) REFERENCES INCIDENT_TYPE(IncidentTypeID),

	-- Creates a relationship between INCIDENT_IN_ROAD_SECTION and ROAD_SECTION
    CONSTRAINT FK_INCIDENT_IN_ROAD_SECTION_OCCURS_IN_ROAD_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID),

	-- Creates a relationship between INCIDENT_IN_ROAD_SECTION and USER
    CONSTRAINT FK_USER_REPORTS_INCIDENT_IN_ROAD_SECTION FOREIGN KEY (UserID) REFERENCES [USER](UserID)
);

/*
Table ROUTE: To record user-requested routes, including start and end points, time, and estimated travel time.
*/
CREATE TABLE [ROUTE] (
    RouteID INT PRIMARY KEY,
    UserID INT NOT NULL, -- A ROUTE must be associated with a USER.
    RouteStartPoint GEOGRAPHY,
    RouteEndPoint GEOGRAPHY,
    DateTimeRequested DATETIME,
    EstimatedTravelTime INT,

	-- Creates a relationship between ROUTE and USER
    CONSTRAINT FK_USER_REQUESTS_ROUTE FOREIGN KEY (UserID) REFERENCES [USER](UserID)
);

/*
Table VEHICLE: To manage and store vehicle information, including registration, model, year, color, 
as well as the associated user/owner of the vehicle.
*/
CREATE TABLE VEHICLE (
    VehicleID INT PRIMARY KEY,
    VehicleRegNo VARCHAR(10),
    UserID INT NOT NULL, -- A VEHICLE must be associated with a USER.
    VehicleModel VARCHAR(50),
    VehicleYear INT,
    VehicleColor VARCHAR(50),

	-- Creates a relationship between VEHICLE and USER
    CONSTRAINT FK_USER_OWNS_VEHICLE FOREIGN KEY (UserID) REFERENCES [USER](UserID)
);

/*
Table ROAD_SURFACE: To store and identify what material a road is made of.
*/
CREATE TABLE ROAD_SURFACE (
    SurfaceID INT PRIMARY KEY,
    SurfaceDescription VARCHAR(100)
);

/*
Table SATELLITE_VIEW: To store street image information.
*/
CREATE TABLE SATELLITE_VIEW (
    SatelliteImageID INT PRIMARY KEY,
    SatelliteImageName NVARCHAR(50),
    SatelliteImageDescription NVARCHAR(100),
    SatelliteImageStoredLocation NVARCHAR(MAX),
    SatelliteImageDateCaptured DATETIME,
    SatelliteImageData VARBINARY(MAX),
    SatelliteImageType VARCHAR(10),
    SatelliteImageSize INT,
    SatelliteImageCoordinates GEOGRAPHY
);

/*
Table STREET_VIEW: To store satellite image information.
*/
CREATE TABLE STREET_VIEW (
    StreetImageID INT PRIMARY KEY,
    StreetImageName NVARCHAR(50),
    StreetImageDescription NVARCHAR(100),
    StreetImageStoredLocation NVARCHAR(MAX),
    StreetImageDateCaptured DATETIME,
    StreetImageData VARBINARY(MAX),
    StreetImageType VARCHAR(10),
    StreetImageSize INT,
    StreetImageCoordinates GEOGRAPHY
);

-- Subtype Entities
/*
Table VEHICLE_SECTION: To define vehicle-specific attributes for road sections, 
and to identify if a road section is for vehicle use.
*/
CREATE TABLE VEHICLE_SECTION (
    RoadSectionID INT PRIMARY KEY,
    SpeedLimit INT CHECK (SpeedLimit BETWEEN 0 AND 999),	-- The speed limit of a vehicle road section must be positive
															-- and below the practical limit of a 1000km/h.
    NoOfLanes INT,
    OneWay_YN BIT,
    Surface_ID INT NOT NULL, -- A VEHICLE_SECTION must be associated with a ROAD_SURFACE.

	-- Creates a relationship between VEHICLE_SECTION and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_IS_A_VEHICLE_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID),

	-- Creates a relationship between VEHICLE_SECTION and ROAD_SURFACE
    CONSTRAINT FK_VEHICLE_SECTION_MADE_OF_ROAD_SURFACE FOREIGN KEY (Surface_ID) REFERENCES ROAD_SURFACE(SurfaceID)
);

/*
Table CYCLE_SECTION: To define cycling-specific attributes for road sections, 
and to identify if a road section is for cycling use.
*/
CREATE TABLE CYCLE_SECTION (
    RoadSectionID INT PRIMARY KEY,
    CyclingLane_YN BIT,

	-- Creates a relationship between CYCLE_SECTION and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_IS_A_CYCLE_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);

/*
Table PEDESTRIAN_SECTION: To define pedestrian-specific attributes for road sections, 
and to identify if a road section is for pedestrian use.
*/
CREATE TABLE PEDESTRIAN_SECTION (
    RoadSectionID INT PRIMARY KEY,
    Pavement_YN BIT,

	-- Creates a relationship between PEDESTRIAN_SECTION and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_IS_A_PEDESTRIAN_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);

/*
Table BUS_SECTION: To define bus-specific attributes for road sections, 
and to identify if a road section is for bus use.
*/
CREATE TABLE BUS_SECTION (
    RoadSectionID INT PRIMARY KEY,

	-- Creates a relationship between BUS_SECTION and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_IS_A_BUS_SECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);

-- Weak Entities
/*
Table ROAD_IN_DISTRICT: To associate roads with districts.
*/
CREATE TABLE ROAD_IN_DISTRICT (
    RoadID INT,
    DistrictID INT,
    PRIMARY KEY (RoadID, DistrictID),

	-- Creates a relationship between ROAD_IN_DISTRICT and ROAD
    CONSTRAINT FK_ROAD_PART_OF_ROAD_IN_DISTRICT FOREIGN KEY (RoadID) REFERENCES ROAD(RoadID),

	-- Creates a relationship between ROAD_IN_DISTRICT and DISTRICT
    CONSTRAINT FK_DISTRICT_CONTAINS_ROAD_IN_DISTRICT FOREIGN KEY (DistrictID) REFERENCES DISTRICT(DistrictID)
);

/*
Table ROAD_SECTION_IN_INTERSECTION: To associate road sections with intersections.
*/
CREATE TABLE ROAD_SECTION_IN_INTERSECTION (
    IntersectionID INT,
    RoadSectionID INT,
    PRIMARY KEY (IntersectionID, RoadSectionID),

	-- Creates a relationship between ROAD_SECTION_IN_INTERSECTION and INTERSECTION
    CONSTRAINT FK_INTERSECTION_CONTAINS_ROAD_SECTION_IN_INTERSECTION FOREIGN KEY (IntersectionID) REFERENCES INTERSECTION(IntersectionID),

	-- Creates a relationship between ROAD_SECTION_IN_INTERSECTION and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_PART_OF_ROAD_SECTION_IN_INTERSECTION FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);

/*
Table ROAD_SECTION_IN_ROUTE: To associate/map road sections with user-requested routes.
*/
CREATE TABLE ROAD_SECTION_IN_ROUTE (
    RouteID INT,
    RoadSectionID INT,
    SequenceInRoute INT NOT NULL CHECK (SequenceInRoute > 0),	-- Each ROAD_SECTION_IN_ROUTE must have a sequence value that determines its position in the route.
																-- That sequence value must be greater than 0.
    PRIMARY KEY (RouteID, RoadSectionID),

	-- Creates a relationship between ROAD_SECTION_IN_ROUTE and ROUTE
    CONSTRAINT FK_ROUTE_CONSISTS_OF_ROAD_SECTION_IN_ROUTE FOREIGN KEY (RouteID) REFERENCES [ROUTE](RouteID),

	-- Creates a relationship between ROAD_SECTION_IN_ROUTE and ROAD_SECTION
    CONSTRAINT FK_ROAD_SECTION_PART_OF_ROAD_SECTION_IN_ROUTE FOREIGN KEY (RoadSectionID) REFERENCES ROAD_SECTION(RoadSectionID)
);