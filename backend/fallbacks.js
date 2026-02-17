const defaultDietPlan = {
    "days": Array.from({ length: 7 }, (_, i) => ({
        "day": i + 1,
        "totalCalories": 2200,
        "protein": "160g",
        "carbs": "220g",
        "fats": "70g",
        "meals": [
            { "title": "Breakfast", "items": [{ "name": "Oatmeal with Protein Powder & Berries", "calories": 500 }] },
            { "title": "Lunch", "items": [{ "name": "Grilled Chicken Breast with Quinoa & Steamed Broccoli", "calories": 700 }] },
            { "title": "Dinner", "items": [{ "name": "Baked Salmon with Sweet Potato & Asparagus", "calories": 800 }] },
            { "title": "Snack", "items": [{ "name": "Greek Yogurt with Almonds", "calories": 200 }] }
        ]
    }))
};

const defaultWorkoutPlan = {
    "gym": {
        "title": "Elite 7-Day Gym Transformation",
        "days": Array.from({ length: 7 }, (_, i) => {
            const day = i + 1;
            const exercises = day % 2 === 0 ? [
                { "id": 1, "name": "Bench Press", "sets": "4", "reps": "10", "calories": 150, "difficulty": "Hard", "equipment": "Barbell" },
                { "id": 2, "name": "Squats", "sets": "4", "reps": "12", "calories": 200, "difficulty": "Hard", "equipment": "Barbell" },
                { "id": 3, "name": "Deadlifts", "sets": "3", "reps": "8", "calories": 250, "difficulty": "Expert", "equipment": "Barbell" }
            ] : [
                { "id": 1, "name": "Pull-ups", "sets": "3", "reps": "AMRAP", "calories": 100, "difficulty": "Medium", "equipment": "Bar" },
                { "id": 2, "name": "Shoulder Press", "sets": "3", "reps": "12", "calories": 120, "difficulty": "Medium", "equipment": "Dumbbells" },
                { "id": 3, "name": "Bicep Curls", "sets": "3", "reps": "15", "calories": 80, "difficulty": "Easy", "equipment": "Dumbbells" }
            ];
            return { "day": day, "exercises": exercises };
        })
    },
    "home": {
        "title": "Ultimate 7-Day Home Fitness",
        "days": Array.from({ length: 7 }, (_, i) => {
            const day = i + 1;
            const exercises = [
                { "id": 1, "name": "Push-ups", "sets": "3", "reps": "20", "calories": 50, "difficulty": "Medium", "equipment": "Bodyweight" },
                { "id": 2, "name": "Bodyweight Squats", "sets": "4", "reps": "25", "calories": 80, "difficulty": "Medium", "equipment": "Bodyweight" },
                { "id": 3, "name": "Plank", "sets": "3", "reps": "60s", "calories": 30, "difficulty": "Easy", "equipment": "Bodyweight" },
                { "id": 4, "name": "Burpees", "sets": "3", "reps": "15", "calories": 100, "difficulty": "Hard", "equipment": "Bodyweight" }
            ];
            return { "day": day, "exercises": exercises };
        })
    }
};

module.exports = { defaultDietPlan, defaultWorkoutPlan };
