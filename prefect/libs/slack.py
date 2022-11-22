import os
import time

from slackclient import SlackClient as client_handler


class SlackClient(object):
    def __init__(self):
        self._login()

    def chat_post_message(self, channel, text, *, delay_hours=0, delay_minutes=0):
        """
        Invokes Slack chat.postMessage API call to post the
        contents of a message to a specified Slack Channel

        :param channel: the channel ID of the Slack channel to post the message to
        :param text: the text content of the message being sent
        :param delay_hours: (optional, default is 0) Number of hours to delay before
            sending message (additive with `delay_minutes`)
        :param delay_minutes: (optional, default is 0) Number of minutes to delay before
            sending message (additive with `delay_hours`)
        """
        if delay_hours > 0 or delay_minutes > 0:
            send_at = time.time() + 60 * delay_minutes + 3600 * delay_hours
            self._sc_client.api_call(
                'chat.scheduleMessage',
                channel=channel,
                text=text,
                post_at=str(send_at)
            )
        else:
            self._sc_client.api_call(
                'chat.postMessage',
                channel=channel,
                text=text
            )

    def channels_invite(self, channel, user):
        """
        Invokes Slack channels.invite API call to invite a given user to the specified channel

        :param channel: the channel ID of the Slack channel to invite the user to
        :param user: the user id of the person being invited
        """
        self._sc_client.api_call('channels.invite',
                                 channel=channel,
                                 user=user)

    def _login(self):
        self._sc_client = client_handler(os.environ['SLACK_BOT_CARL_TOKEN'])


_client = None


def get_client():
    """
    Returns client singleton
    """
    global _client
    if not _client:
        _client = SlackClient()
    return _client
