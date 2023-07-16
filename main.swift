//
//  main.swift
//  ApiToDB
//
//  Created by Иван on 31.05.2022.
//

import Foundation
import SQLite3
// structs for using API
struct Response: Codable
{

    let id: Int
    let type: String?
    let name: String
    let description: String
    let year: Int
    let alternativeName: String?
    let enName: String?
    let movieLength: Int?
    let ageRating: Int?
    let genres: [Genres]
    let countries: [Countries]
    let persons: [Persons]
    let rating: Rating
    let shortDescription: String?
    let poster: Posters
}

struct Rating: Codable
{
    
    let _id: String?
    let kp: Double?
    let imdb: Double?
    let filmCritics: Double?
    let russianFilmCritics: Double?
    let await: Double?
}
struct Genres: Codable
{
    let name: String?
}
struct Countries: Codable
{
    let name: String?

}
struct Persons: Codable
{
    let id: Int
    let name: String
    let enProfession: String
}
struct Posters: Codable
{
    let _id: String?
    let url: String?
    let previewUrl: String?
}
//end for structs

// variables to add in database
//Film
var idFilm =  Int()
var nameFilm = String()
var descriptionFilm = String()
var yearFilm = Int()
var countryFilm = String()
var genreFilm = String()
var age_limitFilm = Int()
var timeFilm = Int()
var ratingFilm = Double()
var imageFilm = String()

//Actor
var idActors = [Int]()
var nameActors = [String]()

//Director
var idDirectors = [Int]()
var nameDirectors = [String]()
//Genres
var genresFilm = [String]()

//end of variables

//start to connect with API
var semaphore = DispatchSemaphore (value: 0)
var newURL = "https://api.kinopoisk.dev/movie?token&field=id&search="//start of the link
//readFile()//function to get IDs to array
//remakeURL()// function to remake URL
//var urlApi = "https://api.kinopoisk.dev/movie?token=NG43E9Y-G6N4VX7-NVXJ02Y-5SRT1AB&field=id&search=2985"
var request = URLRequest(url: URL(string: newURL)!,timeoutInterval: Double.infinity)// api source
request.httpMethod = "GET"// method GET
print(newURL)

var getMass = [String]()// array which will have all IDs


let task = URLSession.shared.dataTask(with: request) { data, response, error in

guard let data = data else {

print(String(describing: error))

return

}
    var result: Response?// get response from api
    do {
        result = try JSONDecoder().decode(Response.self, from: data)
    }
    catch{
        print("Failed to convert \(error)")
    }
    let json = result           //getting json from result
    //print(json)
    print(json?.name)
    print(json?.countries.count)
    print(json?.description)
    // getting json for variables
    //Film
    idFilm = json!.id
    nameFilm = json!.name
    descriptionFilm = json!.description
    yearFilm = json!.year
    countryFilm = json!.countries[0].name!
    genreFilm = json!.genres[0].name!
    age_limitFilm = json!.ageRating!
    timeFilm = json!.movieLength!
    ratingFilm = json!.rating.kp!
    imageFilm = json!.poster.url!
    //
    
    print("id=\(idFilm), name of film = \(nameFilm), description is \(descriptionFilm), year is \(yearFilm), country is \(countryFilm)")
    
    
    
    
    
semaphore.signal()

}                //while we reading json from api



task.resume()

semaphore.wait()



func readFile()                     // function to read file
{
let file = "IDs.txt"                //this is the file. we will write to and read from it


if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

let fileURL = dir.appendingPathComponent(file)
        do {
            
                
            let allIDS = try String(contentsOf: fileURL, encoding: .utf8)
            getMass = allIDS.components(separatedBy: "\n")

            print(getMass.count)
            print(getMass[0])

        }
        catch {print("Error is \(error)")}
}

}

func remakeURL(h: Int)// function which remake url to make request to api with different api
{
    newURL = newURL + getMass[h]
    print(newURL)
    
    
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



var db : OpaquePointer?

    var path : String = "FilmsDB.db"            //name of the database
    
    
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathExtension(path)
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            print("There is error in creating DB")
            return nil
        }else {
            print("Database has been created with path \(path)")
            return db
        }
    }
db = createDB()// creating database from function

func insertToFilm(id: Int, name: String, description: String, year: Int, country: String, age_limit: Int, time: Int, rating: Double)// insert into Film  table
{
    let query = "INSERT INTO Film (id, name, description, year, country, age_limit, time, rating, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(id))
        sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (description as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 4, Int32(year))
        sqlite3_bind_text(statement, 5, (country as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 6, Int32(age_limit))
        sqlite3_bind_int(statement, 7, Int32(time))
        sqlite3_bind_double(statement, 8, Double(rating))
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted in Film table success")
        }else {
            print("Data is not inserted in Film table")
        }
    } else {
      print("Query is not as per requirement")
    }
    
        

        
    }
func insertToActor(id: Int, name: String)// insert to Actor table
{
    let query = "INSERT INTO Actor (id, name) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(id))
        sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
       
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Actor table success")
        }
        else {
            print("Data is not inserted in Actor table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }
func insertToDirector(id: Int, name: String)// insert to Director table
{
    let query = "INSERT INTO Director (id, name) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(id))
        sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
       
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Director table success")
        }
        else {
            print("Data is not inserted in Director table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }
func insertToActor_film(idActor: Int, idFilm: Int)// insert to Actor_film table
{
    let query = "INSERT INTO Actor_film (idActor, idFilm) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(idActor))
        sqlite3_bind_int(statement, 2, Int32(idFilm))

        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Actor_film table success")
        }
        else {
            print("Data is not inserted in Actor_film table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }
func insertToDirector_film(idDirector: Int, idFilm: Int)// insert to Director_film table
{
    let query = "INSERT INTO Director_film (idDirector, idFilm) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(idDirector))
        sqlite3_bind_int(statement, 2, Int32(idFilm))

        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Director_film table success")
        }
        else {
            print("Data is not inserted in Director_film table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }
func insertToGenre(id: Int, name: String)// insert to Genre table
{
    let query = "INSERT INTO Genre (id, name) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(id))
        sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
       
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Genre table success")
        }
        else {
            print("Data is not inserted in Genre table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }
func insertToGenre_film(idGenre: Int, idFilm: Int)// insert to Genre_film table
{
    let query = "INSERT INTO Genre_film (idGenre, idFilm) VALUES (?, ?)"
    var statement : OpaquePointer? = nil

    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
        
        sqlite3_bind_int(statement, 1, Int32(idGenre))
        sqlite3_bind_int(statement, 2, Int32(idFilm))

        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Data inserted to Genre_film table success")
        }
        else {
            print("Data is not inserted in Genre_film table")
        }
    }
    else {
      print("Query is not as per requirement")
    }
        
    }


insertToFilm(id: idFilm, name: nameFilm, description: descriptionFilm, year: yearFilm, country: countryFilm, age_limit: age_limitFilm, time: timeFilm, rating: ratingFilm)
var j = 0
var newArray = [String]()// new array for adding to database which will have limit IDs film
let countOfIDs = 3
for j in 0...countOfIDs - 1
{
    newArray[j] = getMass[j]
}
var i = 0
readFile()
for i in 0...newArray.count
{
    remakeURL(h: i)// remake url
    
}
