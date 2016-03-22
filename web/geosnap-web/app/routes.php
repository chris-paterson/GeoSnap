<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the Closure to execute when that URI is requested.
|
*/

use Parse\ParseObject;
Parse\ParseClient::initialize('yRxNdukOZCMQD9jRrxRMevl6mlEy8uA0M9TgAvmF', 
        'mEmX6ZTOkZj2pfsN0nb8ZQNnUjWkFGuQSKNsqJjm', 
        'VlJkPaGucGAyN9SarlnZF55yd6pd6SfCkeLC1oOD');


Route::get('/', array(
    'as' => 'home',
    'uses' => 'AdminController@home'
));

Route::get('login', array(
    'as' => 'login',
    'uses' => 'UserController@login'
));

Route::post('login', function () {
    $userInfo = Input::only('username', 'password');

    try {
        $user = Parse\ParseUser::logIn($userInfo["username"], $userInfo["password"]);
        if ($user->isAdmin) {
          return Redirect::route("home");
        }
    } catch (ParseException $error) {
    }

    return Redirect::route('login')
        ->withInput();


    // try {
    //   $user = ParseUser::logIn("Chris", "a");
    // } catch (ParseException $error) {
    //   // The login failed. Check error to see why.
    // }
});