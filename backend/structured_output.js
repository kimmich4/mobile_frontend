function parseJsonIfNeeded(value) {
    if (typeof value === "string") return JSON.parse(value);
    return value;
}

function extractTargetCalories(text) {
    const source = String(text || "");
    const patterns = [
        /Target Daily Calories \(adjusted for goal\):\s*(\d+)/i,
        /TARGET CALORIES:\s*(\d+)/i,
        /totalCalories"?\s*:\s*(\d+)/i
    ];

    for (const pattern of patterns) {
        const match = source.match(pattern);
        if (match) return Number(match[1]);
    }

    return 0;
}

function toArray(value) {
    return Array.isArray(value) ? value : [];
}

function numberOrZero(value) {
    const number = Number(value);
    return Number.isFinite(number) ? Math.max(0, Math.round(number)) : 0;
}

function sumMealCalories(meals) {
    return toArray(meals).reduce((dayTotal, meal) => {
        return dayTotal + toArray(meal.items).reduce((mealTotal, item) => {
            return mealTotal + numberOrZero(item.calories);
        }, 0);
    }, 0);
}

function normalizeMeal(title, value) {
    if (value && typeof value === "object" && Array.isArray(value.items)) {
        return {
            title: String(value.title || title || "Meal"),
            items: value.items.map((item) => ({
                name: String(item.name || item.food || item.item || "Meal item"),
                calories: numberOrZero(item.calories)
            }))
        };
    }

    if (Array.isArray(value)) {
        return {
            title: String(title || "Meal"),
            items: value.map((item) => {
                if (item && typeof item === "object") {
                    return {
                        name: String(item.name || item.food || item.item || "Meal item"),
                        calories: numberOrZero(item.calories)
                    };
                }
                return { name: String(item), calories: 0 };
            })
        };
    }

    return {
        title: String(title || "Meal"),
        items: [{ name: String(value || "Meal item"), calories: 0 }]
    };
}

function balanceDietDayCalories(day, fallbackCalories = 0) {
    const target = numberOrZero(day.totalCalories) || fallbackCalories;
    if (!target || !Array.isArray(day.meals) || day.meals.length === 0) {
        return { ...day, totalCalories: sumMealCalories(day.meals) };
    }

    return { ...day, totalCalories: sumMealCalories(day.meals) || target };
}

function normalizeDietDay(rawDay, index, fallbackCalories) {
    const day = rawDay && typeof rawDay === "object" ? rawDay : {};
    let meals = [];

    if (Array.isArray(day.meals)) {
        meals = day.meals.map((meal, mealIndex) => normalizeMeal(meal.title || `Meal ${mealIndex + 1}`, meal));
    } else {
        const ignored = new Set(["day", "totalCalories", "protein", "carbs", "fats", "meals"]);
        meals = Object.entries(day)
            .filter(([key]) => !ignored.has(key))
            .map(([key, value]) => normalizeMeal(key.replace(/_/g, " "), value));
    }

    return balanceDietDayCalories({
        day: numberOrZero(day.day) || index + 1,
        totalCalories: numberOrZero(day.totalCalories) || fallbackCalories || sumMealCalories(meals),
        protein: day.protein ? String(day.protein) : "0g",
        carbs: day.carbs ? String(day.carbs) : "0g",
        fats: day.fats ? String(day.fats) : "0g",
        meals
    }, fallbackCalories);
}

function normalizeDietPlan(input, context = "") {
    const parsed = parseJsonIfNeeded(input);
    const fallbackCalories = extractTargetCalories(context);
    let rawDays = parsed?.days;

    if (!Array.isArray(rawDays) && parsed?.["7_day_diet_plan"]) {
        const dietPlan = parsed["7_day_diet_plan"];
        rawDays = Array.isArray(dietPlan)
            ? dietPlan
            : Object.entries(dietPlan).map(([key, value]) => ({
                day: numberOrZero(String(key).match(/\d+/)?.[0]),
                ...(value && typeof value === "object" ? value : { meals: [value] })
            }));
    }

    return {
        days: toArray(rawDays).map((day, index) => normalizeDietDay(day, index, fallbackCalories))
    };
}

function normalizeExercise(raw, index) {
    if (raw && typeof raw === "object") {
        return {
            id: numberOrZero(raw.id) || index + 1,
            name: String(raw.name || raw.exercise || "Exercise"),
            difficulty: String(raw.difficulty || "Medium"),
            equipment: String(raw.equipment || "None"),
            sets: String(raw.sets || "3"),
            reps: String(raw.reps || "10"),
            calories: numberOrZero(raw.calories)
        };
    }

    const text = String(raw || "Exercise");
    return {
        id: index + 1,
        name: text.replace(/\s*\(.+\)\s*$/, ""),
        difficulty: "Medium",
        equipment: "None",
        sets: "3",
        reps: "10",
        calories: 0
    };
}

function normalizeWorkoutPlan(input) {
    const parsed = parseJsonIfNeeded(input);
    if (parsed?.gym?.days && parsed?.home?.days) return parsed;

    const days = toArray(parsed?.["7_day_exercise_plan"]);
    return {
        gym: {
            title: "Gym Workout Plan",
            days: days.map((day, index) => ({
                day: numberOrZero(day.day) || index + 1,
                exercises: toArray(day.gym_workout || day.gym || day.exercises).map(normalizeExercise)
            }))
        },
        home: {
            title: "Home Workout Plan",
            days: days.map((day, index) => ({
                day: numberOrZero(day.day) || index + 1,
                exercises: toArray(day.home_workout || day.home || day.exercises).map(normalizeExercise)
            }))
        }
    };
}

function extractContraindications(context) {
    const source = String(context || "").toLowerCase();
    const foodsMatch = source.match(/foods to avoid\s*\(([^)]*)\)/i);
    const exercisesMatch = source.match(/exercises to avoid\s*\(([^)]*)\)/i);
    const split = (value) => String(value || "")
        .split(",")
        .map((item) => item.trim().toLowerCase())
        .filter(Boolean);

    return {
        foods: split(foodsMatch?.[1]),
        exercises: split(exercisesMatch?.[1])
    };
}

function replaceName(name, blocked) {
    const lower = String(name || "").toLowerCase();
    const match = blocked.find((item) => item && lower.includes(item));
    return match ? `Safe substitute for ${match}` : name;
}

function replaceContraindicatedNames(plan, contraindications) {
    for (const day of toArray(plan.days)) {
        for (const meal of toArray(day.meals)) {
            for (const item of toArray(meal.items)) {
                item.name = replaceName(item.name, contraindications.foods);
            }
        }
    }

    for (const section of [plan.gym, plan.home]) {
        for (const day of toArray(section?.days)) {
            for (const exercise of toArray(day.exercises)) {
                exercise.name = replaceName(exercise.name, contraindications.exercises);
            }
        }
    }

    return plan;
}

function enforceStructuredPlan(answer, context = "", task = "") {
    const lowerTask = String(task).toLowerCase();
    const normalized = lowerTask.includes("diet")
        ? normalizeDietPlan(answer, context)
        : normalizeWorkoutPlan(answer);

    return JSON.stringify(replaceContraindicatedNames(normalized, extractContraindications(context)));
}

module.exports = {
    extractContraindications,
    normalizeDietPlan,
    normalizeWorkoutPlan,
    enforceStructuredPlan
};
