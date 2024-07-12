#!/usr/bin/swift

import Foundation

struct MonsterList: Codable {
    let count: Int
    let results: [MonsterEntry]
}

struct MonsterEntry: Codable {
    let name: String
    let slug: String
}

let listURL = URL(string:"https://raw.githubusercontent.com/Tuomari-ua/tuomari-ua.github.io/main/gen/monsters.json")!
let jsonData = try String(contentsOf: listURL).data(using: .utf8)!
let monsterList: MonsterList = try JSONDecoder().decode(MonsterList.self, from: jsonData)

try monsterList.results.forEach { entry in
    let URL = URL(string: "https://raw.githubusercontent.com/Tuomari-ua/tuomari-ua.github.io/main/srd/_monsters/" + entry.slug + ".md")!
    try convertFile(from: URL) 
}

func generateMonstersJSON() throws {
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let path = documentURL.appendingPathComponent("Tuomari").absoluteURL
    let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
    try createWholeJSON(urls: directoryContents)
}

func createWholeJSON(urls: [URL]) throws {
    var jsonObject = [String: Any]()
    let count = urls.count
    jsonObject["count"] = count
    var resultsArray = [[String: String]]()
    
    try urls.forEach { url in
        var monster = [String: String]()
        let string = try String(contentsOf: url, encoding: .utf8)
        let slug = url.lastPathComponent.slice(to: ".md")!
        monster["slug"] = slug
        monster["name"] = string.slice(from: "title: ", to: "\n")
        resultsArray.append(monster)
    }
    resultsArray.sort { left, right in
        left["name"] ?? "" < right["name"] ?? ""
    }
    
    jsonObject["results"] = resultsArray
    
    // Output
    let jsonFile = try JSONSerialization.data(withJSONObject: jsonObject)
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let path = documentsURL.appendingPathComponent("monsters.json")
    try jsonFile.write(to: path)
}

func convertFile(from url: URL) throws {
    let string = try String(contentsOf: url, encoding: .utf8)
    var jsonObject = [String: Any]()
    let slug = url.lastPathComponent.slice(to: ".md")!
    
    jsonObject["slug"] = slug
    jsonObject["name"] = string.slice(from: "title: ", to: "\n")
    
    let mainString = string.slice(from: "_", to: "_")?.trimmed()
    let alignmentComponents = mainString?.split(separator: ",")
    let mainComponents = alignmentComponents?[0].split(separator: " ")
    let type = mainComponents?[0]
    let size = mainComponents?[1]
    let subtype = (mainComponents?.count ?? 0 >= 4 ? mainComponents?[3] : "") ?? ""
    
    let alignment = alignmentComponents?.last
    
    jsonObject["type"] = type ?? ""
    jsonObject["subtype"] = String(subtype).slice(from: "(", to: ")") ?? ""
    jsonObject["size"] = getSizeString(from: String(size!)) 
    jsonObject["alignment"] = alignment ?? ""
    
    let armorString = string.slice(from: "**Клас захисту", to: "\n")?.trimmed()
    
    jsonObject["armor_class"] = armorString?.slice(from: "** ", to: " ") ?? ""
    jsonObject["armor_desc"] = armorString?.slice(from: "(", to: ")") ?? ""
    
    let hpString = string.slice(from: "**Пункти здоров'я", to: "\n")?.trimmed()
    
    jsonObject["hit_points"] = hpString?.slice(from: "** ", to: " ") ?? ""
    jsonObject["hit_dice"] =  hpString?.slice(from: "(", to: ")") ?? ""
    
    let speedString = string.slice(from: "**Швидкість", to: "\n")?.trimmed()
    
    var speedDict = [String : Any]()
    
    speedDict["walk"] = speedString?.slice(from: "** ", to: ",")
    speedDict["swim"] = speedString?.sliceOrEnd(from: "плавання ", to: ",")
    speedDict["fly"] = speedString?.sliceOrEnd(from: "політ ", to: ",")
    jsonObject["speed"] = speedDict
    let statString = string.allSlices(from: "\n|", to: "|\n").last?.trimmed()
    let statComponents = statString?.components(separatedBy: " | ")
    
    jsonObject["strength"] = statComponents?[0].slice(to: " (") ?? ""
    jsonObject["dexterity"] =  statComponents?[1].slice(to: " (") ?? ""
    jsonObject["constitution"] = statComponents?[2].slice(to: " (") ?? ""
    jsonObject["intelligence"] = statComponents?[3].slice(to: " (") ?? ""
    jsonObject["wisdom"] = statComponents?[4].slice(to: " (") ?? ""
    jsonObject["charisma"] = statComponents?[0].slice(to: " (") ?? ""
    
    let saveString = string.slice(from: "**Рятівні кидки**", to: "\n")?.trimmed()
    
    jsonObject["strength_save"] = saveString?.sliceOrEnd(from: "Сил +", to: ",") ?? ""
    jsonObject["dexterity_save"] = saveString?.sliceOrEnd(from: "Спр +", to: ",") ?? ""
    jsonObject["constitution_save"] = saveString?.sliceOrEnd(from: "Ста +", to: ",") ?? ""
    jsonObject["intelligence_save"] = saveString?.sliceOrEnd(from: "Інт +", to: ",") ?? ""
    jsonObject["wisdom_save"] = saveString?.sliceOrEnd(from: "Мдр +", to: ",") ?? ""
    jsonObject["charisma_save"] = saveString?.sliceOrEnd(from: "Хар +", to: ",") ?? ""
    
    jsonObject["damage_vulnerabilities"] = string.slice(from: "**Вразливість до ушкоджень** ", to: "\n")?.trimmed() ?? ""
    jsonObject["damage_resistances"] = string.slice(from: "**Стійкість до ушкоджень** ", to: "\n")?.trimmed() ?? ""
    jsonObject["damage_immunities"] = string.slice(from: "**Імунітет до ушкоджень** ", to: "\n")?.trimmed() ?? ""
    jsonObject["condition_immunities"] =  string.slice(from: "**Імунітет до станів** ", to: "\n")?.trimmed() ?? ""
    jsonObject["senses"] = string.slice(from: "**Чуття** ", to: "\n")?.trimmed() ?? ""
    jsonObject["languages"] = string.slice(from: "**Мови** ", to: "\n")?.trimmed() ?? ""
    jsonObject["challenge_rating"] = string.slice(from: "**Небезпека** ", to: " (") ?? ""
    
    let skillsString = string.slice(from: "**Навички**", to: "\n")?.trimmed()
    var skillsDict = [String : Any]()
    
    skillsDict["акробатика"] = skillsString?.sliceOrEnd(from: "Акробатика +", to: ",")
    skillsDict["приборкання тварин"] = skillsString?.sliceOrEnd(from: "Приборкання тварин ", to: ",")
    skillsDict["аркана"] = skillsString?.sliceOrEnd(from: "Аркана +", to: ",")
    skillsDict["атлетика"] = skillsString?.sliceOrEnd(from: "Атлетика +",to: ",")
    skillsDict["обман"] = skillsString?.sliceOrEnd(from: "Обман +",to: ",")
    skillsDict["історія"] = skillsString?.sliceOrEnd(from: "Історія +",to: ",")
    skillsDict["здогадливість"] = skillsString?.sliceOrEnd(from: "Здогадливість +", to: ",")
    skillsDict["залякування"] = skillsString?.sliceOrEnd(from: "Залякування +", to: ",")
    skillsDict["розслідування"] = skillsString?.sliceOrEnd(from: "Розслідування +", to: ",")
    skillsDict["медицина"] = skillsString?.sliceOrEnd(from: "Медицина +", to: ",")
    skillsDict["природа"] = skillsString?.sliceOrEnd(from: "Природа +", to: ",")
    skillsDict["сприйняття"] = skillsString?.sliceOrEnd(from: "Увага +", to: ",")
    skillsDict["артистичність"] = skillsString?.sliceOrEnd(from: "Артистичність +", to: ",")
    skillsDict["переконливість"] = skillsString?.sliceOrEnd(from: "Переконливість +", to: ",")
    skillsDict["релігія"] = skillsString?.sliceOrEnd(from: "Релігія +", to: ",")
    skillsDict["спритність рук"] = skillsString?.sliceOrEnd(from: "Спритність рук +", to: ",")
    skillsDict["непомітність"] = skillsString?.sliceOrEnd(from: "Непомітність +", to: ",")
    skillsDict["виживання"] = skillsString?.sliceOrEnd(from: "Виживання +", to: ",")
    jsonObject["skills"] = skillsDict
    
    // Abilities
    let abilitiesString = string.sliceOrEnd(from: "ПД)", to: "###")
    jsonObject["special_abilities"] = populateActions(from: abilitiesString)
    
    // Actions
    let actionsString = string.sliceOrEnd(from: "Дії", to: "###")
    jsonObject["actions"] = populateActions(from: actionsString)
    
    // Legendary
    let legendarySlice = string.slice(from: "### Легендарні дії\n")
    let legendaryDesc = legendarySlice?.slice(to: "\n")?.trimmed()
    let legendaryString = populateActions(from: legendarySlice?.slice(from: "\n"))
    
    jsonObject["legendary_desc"] = legendaryDesc ?? ""
    jsonObject["legendary_actions"] = legendaryString.isEmpty ? "" : legendaryString
    
    // Reactions
    let reactionsString = string.sliceOrEnd(from: "### Реакції", to: "###")
    jsonObject["reactions"] = populateActions(from: reactionsString) 
    
    // Output
    let jsonFile = try JSONSerialization.data(withJSONObject: jsonObject)
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let jsonPath = documentsURL.appendingPathComponent("jsonData")
    try FileManager.default.createDirectory(atPath: jsonPath.path, withIntermediateDirectories: true, attributes: nil)
    let path = jsonPath.appendingPathComponent("\(slug).json")
    try jsonFile.write(to: path)
}

func populateActions(from string: String?) -> [Any] {
    let actions = string?.components(separatedBy: "\n**").filter { !$0.isEmpty }
    var actionsArray = [Any]()
    
    guard let actions else {
        return []
    }
    
    for action in actions {
        var dict = [String : Any]()
        dict["name"] = action.slice(to: ".**")?.trimmed()
        dict["desc"] = action.slice(from: "**")?.trimmed()
        if !dict.isEmpty {
            actionsArray.append(dict)
        }
    }
    
    return actionsArray
}

func getSizeString(from: String) -> String {
    switch from {
    case "крихітного":
        return "tiny"
    case "малого":
        return "small"
    case "середнього":
        return "medium"
    case "великого":
        return "large"
    case "величезного":
        return "huge"
    case "гігантського":
        return "gargantuan"
    default:
        return "medium"
    }
}
