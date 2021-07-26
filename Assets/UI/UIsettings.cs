using UnityEngine;
using UnityEngine.UI;

public class UIsettings : MonoBehaviour
{
    public static Color UIcolor = new Color(0.074f, 1f, 0.09f);
    public static Color StartUIcolor = new Color(1f, 1f, 1f);

    void Start()
    {
        UpdateColor();
    }

    public void UpdateColor()
    {
        foreach (Text text in FindObjectsOfType<Text>()) if (text.color.r == StartUIcolor.r && text.color.g == StartUIcolor.g && text.color.b == StartUIcolor.b)
            {
                UIcolor.a = text.color.a;
                text.color = UIcolor;
            }
        foreach (Image image in FindObjectsOfType<Image>()) if (image.color.r == StartUIcolor.r && image.color.g == StartUIcolor.g && image.color.b == StartUIcolor.b)
            {
                UIcolor.a = image.color.a;
                image.color = UIcolor;
            }
    }
}
