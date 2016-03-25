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
use Parse\ParseClient;
use Parse\ParseUser;

session_start();

ParseClient::initialize('yRxNdukOZCMQD9jRrxRMevl6mlEy8uA0M9TgAvmF', 
        'mEmX6ZTOkZj2pfsN0nb8ZQNnUjWkFGuQSKNsqJjm', 
        'VlJkPaGucGAyN9SarlnZF55yd6pd6SfCkeLC1oOD');

ParseClient::setStorage( new Parse\ParseSessionStorage() );


Route::post('login', function () {
    $userInfo = Input::only('username', 'password');

    try {
        $user = ParseUser::logIn($userInfo["username"], $userInfo["password"]);

        if ($user->isAdmin) {
          return Redirect::route("home");
        }
    } catch (ParseException $error) {
    }

    return Redirect::route('login')
        ->withInput();
});

Route::get('/', array(
    'as' => 'home',
    'uses' => 'AdminController@home'
));

Route::get('login', array(
    'as' => 'login',
    'uses' => 'UserController@login'
));

Route::get('index', array(
    'as' => 'index',
    'uses' => 'AdminController@index'
));

Route::post('delete-item', array(
    'as' => 'delete-item',
    'uses' => 'AdminController@deleteItem'
));

Route::post('allow-item', array(
    'as' => 'allow-item',
    'uses' => 'AdminController@allowItem'
));