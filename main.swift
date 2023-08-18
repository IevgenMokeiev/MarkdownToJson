#!/usr/bin/swift

import Foundation

let fileURL = URL(string: "https://raw.githubusercontent.com/Tuomari-ua/tuomari-ua.github.io/main/srd/_monsters/gladiator.md")!
let string = try String(contentsOf: fileURL, encoding: .utf8)
var jsonObject = [String: Any]()
let slug = fileURL.relativeString.slice(from: "_monsters/", to: ".md")!

jsonObject["slug"] = slug
jsonObject["name"] = string.slice(from: "title: ", to: "\n")

let mainComponents = string.slice(from: "_", to: "_")?.trimmed().split(separator: " ")
let type = mainComponents?[0]
let size = mainComponents?[1]
let alignment = mainComponents?.last

jsonObject["type"] = type
jsonObject["size"] = size
jsonObject["alignment"] = alignment

let armorString = string.slice(from: "**Клас захисту", to: "\n")?.trimmed()

jsonObject["armor_class"] = armorString?.slice(from: "** ", to: " ")
jsonObject["armor_desc"] = armorString?.slice(from: "(", to: ")")

let hpString = string.slice(from: "**Пункти здоров'я", to: "\n")?.trimmed()

jsonObject["hit_points"] = hpString?.slice(from: "** ", to: " ")
jsonObject["hit_dice"] =  hpString?.slice(from: "(", to: ")")

let speedString = string.slice(from: "**Швидкість", to: "\n")?.trimmed()

var speedDict = [String : Any]()

speedDict["walk"] = speedString?.slice(from: "** ", to: ",")
speedDict["swim"] = speedString?.slice(from: "плавання ", to: [",", "."])
speedDict["fly"] = speedString?.slice(from: "політ ", to: [",", "."])
jsonObject["speed"] = speedDict
let statString = string.allSlices(from: "\n|", to: "|\n").last?.trimmed()
let statComponents = statString?.components(separatedBy: " | ")

jsonObject["strength"] = statComponents?[0].slice(to: " (")
jsonObject["dexterity"] =  statComponents?[1].slice(to: " (")
jsonObject["constitution"] = statComponents?[2].slice(to: " (")
jsonObject["intelligence"] = statComponents?[3].slice(to: " (")
jsonObject["wisdom"] = statComponents?[4].slice(to: " (")
jsonObject["charisma"] = statComponents?[0].slice(to: " (")

let saveString = string.slice(from: "**Рятівні кидки**", to: "\n")?.trimmed()

jsonObject["strength_save"] = saveString?.sliceOrEnd(from: "Сил +", to: ",")
jsonObject["dexterity_save"] = saveString?.sliceOrEnd(from: "Спр +", to: ",")
jsonObject["constitution_save"] = saveString?.sliceOrEnd(from: "Ста +", to: ",")
jsonObject["intelligence_save"] = saveString?.sliceOrEnd(from: "Інт +", to: ",")
jsonObject["wisdom_save"] = saveString?.sliceOrEnd(from: "Мдр +", to: ",")
jsonObject["charisma_save"] = saveString?.sliceOrEnd(from: "Хар +", to: ",")

jsonObject["damage_vulnerabilities"] = string.slice(from: "**Вразливість до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["damage_resistances"] = string.slice(from: "**Стійкість до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["damage_immunities"] = string.slice(from: "**Імунітет до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["condition_immunities"] =  string.slice(from: "**Імунітет до станів** ", to: "\n")?.trimmed()
jsonObject["senses"] = string.slice(from: "**Чуття** ", to: "\n")?.trimmed()
jsonObject["languages"] = string.slice(from: "**Мови** ", to: "\n")?.trimmed()
jsonObject["challenge_rating"] = string.slice(from: "**Небезпека** ", to: "(")

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

let abilitiesString = string.slice(from: "ПД)\n", to: "###")
jsonObject["special_abilities"] = populateActions(from: abilitiesString)

// Actions
let actionsString = string.sliceOrEnd(from: "Дії\n", to: "###")
jsonObject["actions"] = populateActions(from: actionsString)

// Legendary

let legendarySlice = string.slice(from: "### Легендарні дії\n")
let legendaryDesc = legendarySlice?.slice(to: "\n")?.trimmed()
let legendaryString = populateActions(from: legendarySlice?.slice(from: "\n"))

jsonObject["legendary_desc"] = legendaryDesc
jsonObject["legendary_actions"] = legendaryString

// Reactions
let reactionsString = string.sliceOrEnd(from: "### Реакції", to: "###")
jsonObject["reactions"] = populateActions(from: reactionsString)

// Output

let jsonFile = try JSONSerialization.data(withJSONObject: jsonObject)
let path = FileManager.default.urls(for: .documentDirectory,
                                    in: .userDomainMask)[0].appendingPathComponent("\(slug).json")
try jsonFile.write(to: path)

print(jsonObject)

//END

func populateActions(from string: String?) -> [Any] {
    let actionNames = string?.allSlices(from: "\n**", to: ".**")
    let actionDesc = string?.allSlices(from: "** ", to: "\n")
    var actionArray = [Any]()

    if let actionNames = actionNames {
        for index in 0..<actionNames.count {
            var dict = [String : Any]()
            dict["name"] = actionNames[index].trimmed()
            dict["desc"] = actionDesc?[index].trimmed()
            actionArray.append(dict)
        }
    }
    
    return actionArray
}

extension String {
    
    func slice(from: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        return String(self[rangeFrom..<self.endIndex])
    }
    
    func slice(to: String) -> String? {
        guard let rangeTo = self.range(of: to)?.lowerBound else { return nil }
        return String(self[self.startIndex..<rangeTo])
    }
    
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
    
    func sliceOrEnd(from: String, to: String) -> String? {
        let slice = slice(from: from, to: to)
        if let slice {
            return slice
        } else {
            return self.slice(from: from)
        }
    }
    
    func slice(from: String, to: [String]) -> String? {
        return to.compactMap { toString in
            if let slice = slice(from:from, to: toString) {
                return slice
            } else {
                return nil
            }
        }.first
    }
    
    func allSlices(from: String, to: String) -> [String] {
        components(separatedBy: from).dropFirst().compactMap { sub in
            (sub.range(of: to)?.lowerBound).flatMap { endRange in
                String(sub[sub.startIndex ..< endRange])
            }
        }
    }
    
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
