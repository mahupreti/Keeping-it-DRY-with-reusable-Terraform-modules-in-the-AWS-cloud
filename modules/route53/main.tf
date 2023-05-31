data "aws_route53_zone" "zone" {
  name         = "mupreti.com.np"
  private_zone = false
}

resource "aws_route53_record" "example" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "mupreti.com.np"
  type    = "A"
  
  alias {
    name                   = var.aws_lb_public_alb_dns_name
    zone_id                = var.aws_lb_public_alb_zone_id
    evaluate_target_health = false
  }

}
