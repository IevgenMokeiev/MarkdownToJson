#!/usr/bin/swift

import Foundation

let fileURL = URL(string: "https://raw.githubusercontent.com/Tuomari-ua/tuomari-ua.github.io/main/srd/_monsters/adult_black_dragon.md")!
let string = try String(contentsOf: fileURL, encoding: .utf8)

var jsonObject = [String: Any]()

jsonObject["slug"] = string.slice(from: "title: ", to: "\n")
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
jsonObject["fly"] = speedDict
let statString = string.allSlices(from: "\n|", to: "|\n").last?.trimmed()
let statComponents = statString?.components(separatedBy: " | ")

jsonObject["strength"] = statComponents?[0].slice(to: " (")
jsonObject["dexterity"] =  statComponents?[1].slice(to: " (")
jsonObject["constitution"] = statComponents?[2].slice(to: " (")
jsonObject["intelligence"] = statComponents?[3].slice(to: " (")
jsonObject["wisdom"] = statComponents?[4].slice(to: " (")
jsonObject["charisma"] = statComponents?[0].slice(to: " (")

let saveString = string.slice(from: "**Рятівні кидки**", to: "\n")?.trimmed()

jsonObject["strength_save"] = saveString?.slice(from: "Сил +", to: ",") ?? saveString?.slice(from: "Сил +")
jsonObject["dexterity_save"] = saveString?.slice(from: "Спр +", to: ",") ?? saveString?.slice(from: "Спр +")
jsonObject["constitution_save"] = saveString?.slice(from: "Ста +", to: ",") ?? saveString?.slice(from: "Ста +")
jsonObject["intelligence_save"] = saveString?.slice(from: "Інт +", to: ",") ?? saveString?.slice(from: "Інт +")
jsonObject["wisdom_save"] = saveString?.slice(from: "Мдр +", to: ",") ?? saveString?.slice(from: "Мдр +")
jsonObject["charisma_save"] = saveString?.slice(from: "Хар +", to: [",", ""]) ?? saveString?.slice(from: "Хар +")

jsonObject["damage_vulnerabilities"] = string.slice(from: "**Вразливість до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["damage_resistances"] = string.slice(from: "**Стійкість до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["damage_immunities"] = string.slice(from: "**Імунітет до ушкоджень** ", to: "\n")?.trimmed()
jsonObject["condition_immunities"] =  string.slice(from: "**Імунітет до станів** ", to: "\n")?.trimmed()

print(jsonObject)

//END

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
