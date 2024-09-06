import 'package:hive/hive.dart';
import 'package:workout_tracker_app/datetime/date_time.dart';
import 'package:workout_tracker_app/models/exercise.dart';
import 'package:workout_tracker_app/models/workout.dart';

class HiveDatabase {
  //reference our hive box
  final _myBox = Hive.box('workout_database1');

  //check if there is already data stored, if not, record the start date
  bool previousDataExists() {
    if (_myBox.isEmpty) {
      print('previous data does not exist');
      _myBox.put('START_DATE', todaysDateYYYYMMDD());
      return false;
    } else {
      print('previous data does exist');
      return true;
    }
  }

  //return start date as yyyymmdd
  String getStartDate() {
    return _myBox.get('START_DATE');
  }

  //write data
  void saveToDataBase(List<Workout> workouts) {
    // convert workout objects into lists of strings so that we can save in hive

    final workoutList = convertObjectToWorkoutList(workouts);
    final exerciseList = convertObjectToExerciseList(workouts);

    if (exerciseCompleted(workouts)) {
      _myBox.put('COMPLETION_STATUS${todaysDateYYYYMMDD()}', 1);
    } else {
      _myBox.put('COMPLETION_STATUSE${todaysDateYYYYMMDD()}', 0);
    }
    
    _myBox.put('WOKOUTS', workoutList);
    _myBox.put('EXERCISES', exerciseList);
  }

  
  List<Workout> readFromDataBase() {
    List<Workout> mySavedWorkouts = [];

    List<String> workoutNames = _myBox.get('WORKOUTS');
    final exerciseDetails = _myBox.get('EXERCISES');

    
    for (int i = 0; i < workoutNames.length; i++) {
      List<Exercise> exercisesInEachWorkout = [];

      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInEachWorkout.add(
          Exercise(
            name: exerciseDetails[i][j][0],
            weight: exerciseDetails[i][j][1],
            reps: exerciseDetails[i][j][2],
            sets: exerciseDetails[i][j][3],
            isCompleted: exerciseDetails[i][j][4] == 'true' ? true : false,
          ),
        );
      }
      
      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);
      
      mySavedWorkouts.add(workout);
    }
    return mySavedWorkouts;
  }
  //check if any exercises have been done

  bool exerciseCompleted(List<Workout> workouts) {
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  //return completion status of a given date yyyymmdd
  int getCompletedStatus(String yyyymmdd) {
    int completionStatus = _myBox.get('COMPLETION_STATUS_$yyyymmdd') ?? 0;
    return completionStatus;
  }
}

//converts workout objects into a list -> eg. [upperbody, lowerbody]
List<String> convertObjectToWorkoutList(List<Workout> workouts) {
  List<String> workoutList = [];

  for (int i = 0; i < workouts.length; i++) {
    workoutList.add(
      workouts[i].name,
    );
  }
  return workoutList;
}

//converts the exercise in a workout object into a list of strings

List<List<List<String>>> convertObjectToExerciseList(List<Workout> workouts) {
  List<List<List<String>>> exerciseList = [];

  //go through each workout
  for (int i = 0; i < workouts.length; i++) {
    //get exercises from each workout
    List<Exercise> exercisesInWorkout = workouts[i].exercises;

    List<List<String>> individualWorkout = [
      //upper body
      //[[biceps, 10kg, 10 reps, 3 sets], [triceps, 20kg, 10reps, 3 sets]],
    ];

    //go through each exercise in exerciseList
    for (int j = 0; j < exercisesInWorkout.length; j++) {
      List<String> individualExercise = [
        //[biceps, 10kg, 10 reps, 3 sets]
      ];

      individualExercise.addAll(
        [
          exercisesInWorkout[j].name,
          exercisesInWorkout[j].weight,
          exercisesInWorkout[j].reps,
          exercisesInWorkout[j].sets,
          exercisesInWorkout[j].isCompleted.toString(),
        ],
      );
      individualWorkout.add(individualExercise);
    }
    exerciseList.add(individualWorkout);
  }
  return exerciseList;
}
