function calculateBMR(weight, height, age, gender) {
    if (gender.toLowerCase() === 'male') {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
}

function calculateTDEE(bmr, activityLevel) {
    const activityMultipliers = {
        'sedentary': 1.2,
        'light': 1.375,
        'moderate': 1.55,
        'active': 1.725,
        'very active': 1.9
    };
    return bmr * (activityMultipliers[activityLevel.toLowerCase()] || 1.375);
}

console.log("--- Testing BMR/TDEE Math ---");
const maleBmr = calculateBMR(81, 180, 23, 'male');
const maleTdee = calculateTDEE(maleBmr, 'very active');
console.log(`Male (81kg, 180cm, 23yr, very active): BMR=${maleBmr.toFixed(2)}, TDEE=${maleTdee.toFixed(2)}`);

const femaleBmr = calculateBMR(60, 165, 25, 'female');
const femaleTdee = calculateTDEE(femaleBmr, 'active');
console.log(`Female (60kg, 165cm, 25yr, active): BMR=${femaleBmr.toFixed(2)}, TDEE=${femaleTdee.toFixed(2)}`);
console.log("-----------------------------");
