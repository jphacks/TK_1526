var sentence:String = "Is it able to extract integer from long sentence, like 'Please wait for three minutes yeah', and the result is five minutes walking"

var numDictionary = [
    "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
    "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15, "sixteen": 16,
    "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20
]

func extractTimeFromSentence(inout str:String) -> (Int) {
    var numInt: Int?
    let splitedSentenceArray: [String] = str.componentsSeparatedByString(" ")
    for tuple in splitedSentenceArray.enumerate() {
        if ((tuple.element == "minute") || (tuple.element == "minutes")) {
            let indexNum = tuple.index-1
            let numStr = splitedSentenceArray[indexNum]
            if Int(numStr) == nil {
                if (numDictionary[numStr] == nil) {
                    numInt = 0
                } else {
                    numInt = numDictionary[numStr]
                }
            } else {
                numInt = Int(numStr)
            }
        }
    }
    return numInt!
}

let num = extractTimeFromSentence(&sentence)
print(num)
