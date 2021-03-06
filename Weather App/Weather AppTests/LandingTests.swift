//
//  LandingTests.swift
//  Weather AppTests
//
//  Created by Sinothando Mabhena on 2022/04/28.
//

import XCTest
import CoreData
@testable import Weather_App

class LandingTests: XCTestCase {
    private var viewModel: LandingViewModel!
    private var delegate: MockDelegate!
    private var repository: MockRepository!
    private var coreDataRepository: MockCoreDataRepository!
    private var offlineRepository: MockOfflineRepository!

    override func setUp() {
        super.setUp()
        self.delegate = MockDelegate()
        self.repository = MockRepository()
        self.coreDataRepository = MockCoreDataRepository()
        self.offlineRepository = MockOfflineRepository()
        self.viewModel = LandingViewModel(repository: repository,
                                          coreDataRepository: coreDataRepository,
                                          offlineRepository: offlineRepository,
                                     delegate: delegate)
    }
    
    func testCorrectCityName() {
        viewModel.fetchWeather()
        guard let cityName = viewModel.city else { return }
        XCTAssertEqual(cityName, "Pretoria")
    }
    
    func testCorrectWeather() {
        viewModel.fetchWeather()
        guard let weather = viewModel.weather?.name else { return }
        XCTAssertEqual(weather, "Cloudy")
    }
    
    func testCorrectWeatherCondition() {
        viewModel.fetchWeather()
        guard let weatherCondition = viewModel.weatherCondition else { return }
        XCTAssertEqual(weatherCondition, "Cloudy")
    }
    
    func testCorrectForecast() {
        viewModel.fetchForecast()
        guard let cityNameForecast = viewModel.forecast?.city?.name else { return }
        XCTAssertEqual(cityNameForecast, "Pretoria")
    }
    
    func testCorrectForecastList() {
        viewModel.fetchForecast()
        guard let forecastList = viewModel.forecastList else { return }
        XCTAssertNotNil(forecastList)
    }
    
    func testCorrectdaysOfWeek() {
       XCTAssertEqual(viewModel.daysOfWeek, ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"])
    }
    
    func testInCorrectForecastCount() {
        viewModel.fetchForecast()
        XCTAssertEqual(viewModel.forecastCount, 0)
    }
    
    func testToday() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let today = dateFormatter.string(from: date)
        XCTAssertEqual(viewModel.today, today)
    }
    
    func testCurrentWeekFromToday() {
        let arrayOfWeeks = [["Fri","Sat","Sun","Mon","Tue"],
                            ["Sat","Sun","Mon","Tue","Wed"],
                            ["Sun","Mon","Tue", "Wed","Thu"],
                            ["Mon","Tue", "Wed","Thu","Fri"],
                            ["Tue", "Wed","Thu","Fri", "Sat"],
                            ["Wed","Thu","Fri", "Sat", "Sun"],
                            ["Thu","Fri", "Sat","Sun","Mon"]]
        
        XCTAssert(arrayOfWeeks.contains(viewModel.currentWeekFromToday))
    }
    
    func testSaveForOfflineState() {
        offlineRepository.shouldFail = true
        viewModel.saveForOfflineState()
        XCTAssert(delegate.showErrorCalled)
    }
    
    func testFetchWeatherFailure() {
        viewModel.fetchWeather()
        XCTAssertFalse(delegate.updateThemeCalled)
    }
    
    class MockDelegate: LandingViewModelDelegate {
        var showErrorCalled = false
        var loadContentCalled = false
        var reloaddViewCalled = false
        var disableButtonCalled = false
        var updateThemeCalled = false
        var updateWeatherCalled = false
        var showOfflineCalled = false
        
        func showOffline(response: [Offline]) {
            showOfflineCalled = true
        }
        
        func show(error: String) {
            showErrorCalled = true
        }
        
        func loadContent() {
            loadContentCalled = true
        }
        
        func reloadView() {
            reloaddViewCalled = true
        }
        
        func disableButton() {
            disableButtonCalled = true
        }
        
        func updateTheme() {
            updateThemeCalled = true
        }
        
        func updateWeather() {
            updateWeatherCalled = true
        }
    }
    
    class TestCoreDataStack: NSObject {
        lazy var persistentContainer: NSPersistentContainer = {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            let container = NSPersistentContainer(name: "Weather_App")
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            return container
        }()
    }
    
    class MockOfflineRepository: OfflineRepositoryType {
        var shouldFail = false
        
        func mockData() -> [Offline] {
            let mockOfflineWeather = Offline()
            var mockOfflines: [Offline] = []
            
            mockOfflines.append(mockOfflineWeather)
            
            return mockOfflines
        }
        
        func createOfflineWeather(weather: Response?, completion: @escaping (CreateOfflineWeather)) {
            if shouldFail {
                completion(.failure(.createError))
            } else {
                completion(.success(()))
            }
        }
        
        func fetchOfflineWeather(completion: @escaping (FetchOfflineWeather)) {
            if shouldFail {
                completion(.failure(.fetchError))
            } else {
                completion(.success(mockData()))
            }
        }
    }
    
    class MockCoreDataRepository: FavouriteRepositoryType {
        var shouldFail = false
        
        func mockData() -> [Location] {
            let mockLocation = Location()
            var mockSavedLocations: [Location] = []
            
            mockSavedLocations.append(mockLocation)
            
            return mockSavedLocations
        }
        
        func createLocationItem(location: Response?, completion: @escaping (CreateLocation)) {
            if shouldFail {
                completion(.failure(.createError))
            } else {
                completion(.success(()))
            }
        }
        
        func fetchSavedLocations(completion: @escaping (SavedLocationsResult)) {
            if shouldFail {
                completion(.failure(.createError))
            } else {
                completion(.success(mockData()))
            }
        }
        
        func isLocationSaved(location: Response?, completion: @escaping (IsLocationSaved)) {
            if shouldFail {
                completion(.failure(.createError))
            } else {
                completion(.success(()))
            }
        }
    }
    
    class MockRepository: LandingRepositoryType {
        var shouldFail = false
        
        let mockForecast: Forecast = Forecast(cod: "cod",
                                              message: 1,
                                              cnt: 1,
                                              list: [List(dt: 1,
                                                          main: ForecastMain(temp: 22.2,
                                                                             feelsLike: 24.2,
                                                                             tempMin: 21.1,
                                                                             tempMax: 24.4,
                                                                             pressure: 1,
                                                                             seaLevel: 1,
                                                                             grndLevel: 1,
                                                                             humidity: 1,
                                                                             tempKf: 43.3),
                                                          weather: [Weather(id: 1,
                                                                            main: "Clear",
                                                                            weatherDescription: "Clear skies",
                                                                            icon: "icon")],
                                                          clouds: Clouds(all: 1),
                                                          wind: Wind(speed: 1.2,
                                                                     deg: 1,
                                                                     gust: 12.3),
                                                          visibility: 1,
                                                          pop: 12.2,
                                                          sys: Sys(type: 1,
                                                                   id: 1,
                                                                   message: 1.1,
                                                                   country: "South Africa",
                                                                   sunrise: 1,
                                                                   sunset: 1,
                                                                   pod: "Pod"),
                                                          dtTxt: "1234")],
                                              city: City(id: 1,
                                                         name: "Pretoria",
                                                         coord: Coord(lon: 12.2,
                                                                      lat: 12.4),
                                                         country: "South Africa",
                                                         population: 1133,
                                                         timezone: 3,
                                                         sunrise: 1,
                                                         sunset: 1))
        
        let mockData: Response = Response(coord: Coord(lon: 23.4, lat: 21.2),
                                          weather: [Weather(id: 1,
                                                            main: "Cloudy",
                                                            weatherDescription: "Cloudy sky",
                                                            icon: "cld")],
                                          base: "stations",
                                          main: Main(temp: 24,
                                                     feelsLike: 26,
                                                     tempMin: 19,
                                                     tempMax: 29,
                                                     pressure: 40,
                                                     humidity: 10),
                                          visibility: 0,
                                          wind: Wind(speed: 12.2,
                                                     deg: 14,
                                                     gust: 9.3),
                                          clouds: Clouds(all: 1),
                                          dt: 1,
                                          sys: Sys(type: 1,
                                                   id: 2,
                                                   message: 2.1,
                                                   country: "South Africa",
                                                   sunrise: 2901,
                                                   sunset: 90,
                                                   pod: "pod"),
                                          timezone: 1,
                                          id: 1,
                                          name: "Pretoria",
                                          cod: 1)
        
        func fetchWeatherResults(_ latitude: String, _ longitude: String, completionHandler: @escaping WeatherResponse) {
            if shouldFail {
                completionHandler(.failure(.serverError))
            } else {
                completionHandler(.success(mockData))
            }
        }
        
        func fetchForecastResults(_ latitude: String, _ longitude: String, completionHandler: @escaping ForecastResponse) {
            if shouldFail {
                completionHandler(.failure(.serverError))
            } else {
                completionHandler(.success(mockForecast))
            }
        }    
    }

}
