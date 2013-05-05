package lol;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import twitter4j.Query;
import twitter4j.QueryResult;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;

public class TwitterDataGenerator {

	private List<String> champions;
	
	public TwitterDataGenerator(List<String> champions)
	{
		this.setChampions(champions);
	}
	
//	public static void main(String[] args) {
//			List<String> champions = Arrays.asList("Amumu", "Cho Gath", "Darius", "Draven", "Garen", "Jarvan", 
//					"Jayce", "Karthus", "Katarina", "Lee Sin", "Lux", "Nidalee", 
//					"Olaf", "Poppy", "Rengar", "Varus", "Wukong", "Xin");
//			TwitterDataGenerator generator = new TwitterDataGenerator(champions);
//			Map<String, Map<String, List<Status>>> tweetsByChampion = generator.getTwitterData();
//			for (String champion : tweetsByChampion.keySet()) {
//				Map<String, List<Status>> resultByDate  = (Map<String, List<Status>>)tweetsByChampion.get(champion);
//				System.out.println("----FOR----: "+ champion);
//			for (String date : resultByDate.keySet()) {
//				System.out.println("KEY: " + date + " COUNT : "	+ resultByDate.get(date).size());
//			}
//			}
//	}
	
	public Map<String, Map<String, List<Status>>> getTwitterData() {
		Map<String, Map<String, List<Status>>> tweetsByChampion = new HashMap<String, Map<String, List<Status>>>();
		
		//ConfigurationBuilder cb = new ConfigurationBuilder();
		//cb.setDebugEnabled(false).setOAuthConsumerKey(oauthConsumerKey).setOAuthConsumerSecret(oauthConsumerSecret).setOAuthAccessToken(oauthAccessToken).setOAuthAccessTokenSecret(oauthAccessTokenSecret);
		try {
			Twitter twitter = new TwitterFactory().getInstance();
			//Twitter twitter = (Twitter) request.getSession().getAttribute("twitter");

				
	
			String hashtag = "#leagueoflegends";
			// List<String> champions = Arrays.asList("Amumu", "Cho Gath",
			// "Darius", "Draven", "Garen", "Jarvan",
			// "Jayce", "Karthus", "Katarina", "Lee Sin", "Lux", "Nidalee",
			// "Olaf", "Poppy", "Rengar", "Varus", "Wukong", "Xin");
			for (String champion : this.getChampions()) {

				System.out.println("Fetching tweets for " + champion);
				String queryString = hashtag + " " + champion;
				Query query = new Query(queryString);
				List<Status> totalTweets = getTweetsForAChampion(twitter, queryString, query);
				if (!totalTweets.isEmpty()) {

					Map<String, List<Status>> resultByDate = aggregateResultsByDate(totalTweets);
//
//					System.out.println("-------------DATA for " + champion
//							+ "---------");
//					for (String date : resultByDate.keySet()) {
//						System.out.println("KEY: " + date + " COUNT : "
//								+ resultByDate.get(date).size());
//					}
					tweetsByChampion.put(champion, resultByDate);
				}

			}

		} catch (TwitterException te) {
			te.printStackTrace();
			System.out.println("Failed to search tweets: " + te.getMessage());
		}
		return tweetsByChampion;
	}
	
	private List<Status> getTweetsForAChampion(Twitter twitter,
			String queryString, Query query) throws TwitterException {
		List<Status> totalTweets = new ArrayList<Status>();
		QueryResult result;
		do {
			result = twitter.search(query);
			List<Status> tweets = result.getTweets();
			totalTweets.addAll(tweets);
			//System.out.println("Each query count- " + tweets.size());
			// for (Status tweet : tweets) {
			// System.out.println("@" + tweet.getCreatedAt() + " - "
			// + tweet.getUser().getScreenName() + " - " + tweet.getText());
			// }
		} while ((query = result.nextQuery()) != null);

		System.out.println("TOTAL COUNT for " + queryString + ": "
				+ totalTweets.size());
		return totalTweets;
	}

	private Map<String, List<Status>> aggregateResultsByDate(
			List<Status> totalTweets) {
		Map<String, List<Status>> resultsByDate = new HashMap<String, List<Status>>();
		for (Status tweet : totalTweets) {
			String dateKey = getFormattedDate(tweet.getCreatedAt());
			List<Status> tweetsPerDate = resultsByDate.get(dateKey);
			if (tweetsPerDate == null || tweetsPerDate.isEmpty()) {
				List<Status> tweets = new ArrayList<Status>();
				tweets.add(tweet);
				resultsByDate.put(dateKey, tweets);
			} else {
				tweetsPerDate.add(tweet);
			}

		}
		return resultsByDate;

	}

	private String getFormattedDate(Date date) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(date);
		String format = calendar.get(Calendar.MONTH) + 1 + "/"
				+ calendar.get(Calendar.DATE) + "/"
				+ calendar.get(Calendar.YEAR);
		return format;
	}

	public List<String> getChampions() {
		return champions;
	}

	public void setChampions(List<String> champions) {
		this.champions = champions;
	}


}
