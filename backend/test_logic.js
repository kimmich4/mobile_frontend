const { calculateBMR, calculateTDEE } = require('./index');

function testCalculations() {
    console.log("--- Testing BMR/TDEE Calculations ---");

    // Test Male 180cm, 80kg, 25yr
    const maleBmr = calculateBMR(80, 180, 25, 'male');
    const maleTdee = calculateTDEE(maleBmr, 'very active');
    console.log(`Male (80kg, 180cm, 25yr, very active): BMR=${maleBmr.toFixed(2)}, TDEE=${maleTdee.toFixed(2)}`);
    // BMR should be approx 88.362 + 1071.76 + 863.82 - 141.925 = 1882.017

    // Test Female 160cm, 55kg, 30yr
    const femaleBmr = calculateBMR(55, 160, 30, 'female');
    const femaleTdee = calculateTDEE(femaleBmr, 'sedentary');
    console.log(`Female (55kg, 160cm, 30yr, sedentary): BMR=${femaleBmr.toFixed(2)}, TDEE=${femaleTdee.toFixed(2)}`);
    // BMR should be approx 447.593 + 508.585 + 495.68 - 129.9 = 1321.958

    console.log("--------------------------------------");
}

// Since index.js starts a server, we can't easily require it without it listening.
// Let's mock the functions here if they were not exported or if index.js structure prevents clean import.
// I'll check if index.js exports them. It doesn't.
// I will temporarily export them in index.js for testing or just copy them here for logic verification.

testCalculations();
