<?php
use Parse\ParseUser;
use Parse\ParseClient;
use Parse\ParseQuery;

class AdminController extends \BaseController {
	public function home() {
		$currentUser = ParseUser::getCurrentUser();
		$username = $currentUser->getUsername();

		return View::make('master', compact('username'));
	}

	/**
	 * Display a listing of the resource.
	 *
	 * @return Response
	 */
	public function index()
	{
		// Get reported items
		$query = new ParseQuery("Report");
		$reportedItems = $query->find();


		// php doesn't have sets so we must create one...
		$reportedComments = [];
		$reportedPosts = [];

		foreach ($reportedItems as $reportedItem) {
			$reportedClass = $reportedItem->get('class');
			$reportedId = $reportedItem->get('reportedItem');

			if ($reportedClass == "Comment") {
				if (!in_array($reportedId, $reportedComments)) {
					array_push($reportedComments ,$reportedId);
				}
			} else {
				if (!in_array($reportedId, $reportedPosts)) {
					array_push($reportedPosts, $reportedId);
				}
			}
		}

		error_log('num comments:' + count($reportedComments));
		error_log('num posts:' + count($reportedPosts));

		$commentQuery = new ParseQuery("Comment");
		$commentQuery->containedIn("objectId", $reportedComments);
		$comments = $commentQuery->find();

		$postQuery = new ParseQuery("Post");
		$postQuery->containedIn("objectId", $reportedPosts);
		$posts = $postQuery->find();

		return View::make('admin.index', compact('comments', 'posts'));
	}


	/**
	 * Show the form for creating a new resource.
	 *
	 * @return Response
	 */
	public function create()
	{
		//
	}


	/**
	 * Store a newly created resource in storage.
	 *
	 * @return Response
	 */
	public function store()
	{
		//
	}


	/**
	 * Display the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function show($id)
	{
		//
	}


	/**
	 * Show the form for editing the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function edit($id)
	{
		//
	}


	/**
	 * Update the specified resource in storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function update($id)
	{
		//
	}


	/**
	 * Remove the specified resource from storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function destroy($id)
	{
		//
	}


}
